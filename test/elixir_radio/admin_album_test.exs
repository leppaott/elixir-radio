defmodule ElixirRadio.AdminAlbumTest do
  use ElixirRadio.ConnCase, async: false

  import ElixirRadio.Factory
  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog

  describe "POST /admin/albums - create album with tracks" do
    setup do
      genre = insert!(:genre, name: "Electronic")
      artist = insert!(:artist, name: "Test Artist")

      %{genre: genre, artist: artist}
    end

    test "creates album with multiple tracks", %{genre: genre, artist: artist} do
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Test Album",
          "artist_id" => artist.id,
          "genre_id" => genre.id,
          "release_year" => 2024,
          "tracks" => [
            %{"title" => "Track 1", "track_number" => 1, "sample_duration" => 120},
            %{"title" => "Track 2", "track_number" => 2, "sample_duration" => 90},
            %{"title" => "Track 3", "track_number" => 3, "sample_duration" => 120}
          ]
        })

      response = json_response(conn, 201)

      assert response["album_id"]
      assert response["title"] == "Test Album"
      assert length(response["tracks"]) == 3

      # Verify tracks are in correct order
      tracks = Enum.sort_by(response["tracks"], & &1["track_number"])
      assert Enum.at(tracks, 0)["title"] == "Track 1"
      assert Enum.at(tracks, 1)["title"] == "Track 2"
      assert Enum.at(tracks, 2)["title"] == "Track 3"

      # Each track should have upload_url
      Enum.each(tracks, fn track ->
        assert track["upload_url"] =~ ~r|/admin/tracks/\d+/upload|
      end)

      # Verify database records
      album = Repo.get!(Catalog.Album, response["album_id"]) |> Repo.preload(:tracks)
      assert album.title == "Test Album"
      assert length(album.tracks) == 3
      assert Enum.all?(album.tracks, &(&1.upload_status == "pending"))
    end

    test "creates album with single track", %{genre: genre, artist: artist} do
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Single Track Album",
          "artist_id" => artist.id,
          "genre_id" => genre.id,
          "tracks" => [
            %{"title" => "Only Track", "track_number" => 1}
          ]
        })

      response = json_response(conn, 201)
      assert response["album_id"]
      assert length(response["tracks"]) == 1
    end

    test "creates album with empty tracks list", %{genre: genre, artist: artist} do
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Empty Album",
          "artist_id" => artist.id,
          "genre_id" => genre.id,
          "tracks" => []
        })

      response = json_response(conn, 201)
      assert response["album_id"]
      assert response["tracks"] == []
    end

    test "returns error when album data is invalid", %{genre: genre} do
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Test Album",
          # Missing required artist_id
          "genre_id" => genre.id,
          "tracks" => []
        })

      response = json_response(conn, 400)
      assert response["errors"]
    end

    test "returns error when track data is invalid", %{genre: genre, artist: artist} do
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Test Album",
          "artist_id" => artist.id,
          "genre_id" => genre.id,
          "tracks" => [
            %{"title" => "Valid Track", "track_number" => 1},
            %{"title" => "Invalid Track"}
            # Missing required track_number
          ]
        })

      response = json_response(conn, 400)
      assert response["errors"]
    end

    test "creates album with optional metadata", %{genre: genre, artist: artist} do
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Detailed Album",
          "artist_id" => artist.id,
          "genre_id" => genre.id,
          "release_year" => 2024,
          "cover_image_url" => "https://example.com/cover.jpg",
          "description" => "A great album",
          "tracks" => [
            %{"title" => "Track 1", "track_number" => 1}
          ]
        })

      response = json_response(conn, 201)
      assert response["album_id"]

      album = Repo.get!(Catalog.Album, response["album_id"])
      assert album.release_year == 2024
      assert album.cover_image_url == "https://example.com/cover.jpg"
      assert album.description == "A great album"
    end
  end

  describe "GET /admin/albums/:id/status" do
    setup do
      genre = insert!(:genre)
      artist = insert!(:artist)
      album = insert!(:album, artist: artist, genre: genre)

      track1 = insert!(:track, album: album, track_number: 1, upload_status: "pending")
      track2 = insert!(:track, album: album, track_number: 2, upload_status: "ready")
      track3 = insert!(:track, album: album, track_number: 3, upload_status: "processing")

      %{album: album, tracks: [track1, track2, track3], genre: genre, artist: artist}
    end

    test "returns album status with track details", %{album: album} do
      conn = build_conn() |> get("/admin/albums/#{album.id}/status")
      response = json_response(conn, 200)

      assert response["album_id"] == album.id
      assert response["title"] == album.title
      assert response["artist"]
      assert response["genre"]
      assert length(response["tracks"]) == 3

      # Tracks should be sorted by track_number
      track_numbers = Enum.map(response["tracks"], & &1["track_number"])
      assert track_numbers == [1, 2, 3]

      # Verify counts
      assert response["total_count"] == 3
      assert response["ready_count"] == 1
      assert response["processing_count"] == 1
      assert response["pending_count"] == 1
      assert response["complete"] == false
    end

    test "shows complete true when all tracks ready", %{album: album, tracks: tracks} do
      # Update all tracks to ready
      Enum.each(tracks, fn track ->
        Catalog.update_track_status(track.id, "ready")
      end)

      conn = build_conn() |> get("/admin/albums/#{album.id}/status")
      response = json_response(conn, 200)

      assert response["complete"] == true
      assert response["ready_count"] == 3
    end

    test "includes upload_url for each track", %{album: album} do
      conn = build_conn() |> get("/admin/albums/#{album.id}/status")
      response = json_response(conn, 200)

      Enum.each(response["tracks"], fn track ->
        assert track["upload_url"] == "/admin/tracks/#{track["id"]}/upload"
      end)
    end

    test "returns 404 for non-existent album" do
      conn = build_conn() |> get("/admin/albums/999999/status")
      response = json_response(conn, 404)

      assert response["error"] == "Album not found"
    end

    test "includes processing status from segments", %{
      album: album,
      tracks: [track1, _track2, _track3]
    } do
      # Add a segment to track1
      insert!(:segment, track_id: track1.id, processing_status: "completed")

      conn = build_conn() |> get("/admin/albums/#{album.id}/status")
      response = json_response(conn, 200)

      track1_data = Enum.find(response["tracks"], &(&1["id"] == track1.id))
      assert track1_data["processing_status"] == "completed"
    end
  end

  describe "integration - create album and upload tracks" do
    test "complete workflow: create album, upload tracks, check status" do
      genre = insert!(:genre)
      artist = insert!(:artist)

      # Step 1: Create album with tracks
      conn =
        build_conn()
        |> post("/admin/albums", %{
          "title" => "Full Album",
          "artist_id" => artist.id,
          "genre_id" => genre.id,
          "tracks" => [
            %{"title" => "Song 1", "track_number" => 1, "sample_duration" => 120},
            %{"title" => "Song 2", "track_number" => 2, "sample_duration" => 120}
          ]
        })

      album_response = json_response(conn, 201)
      album_id = album_response["album_id"]
      [track1, track2] = album_response["tracks"]

      # Step 2: Check initial status
      conn = build_conn() |> get("/admin/albums/#{album_id}/status")
      status = json_response(conn, 200)

      assert status["pending_count"] == 2
      assert status["ready_count"] == 0
      assert status["complete"] == false

      # Step 3: Upload first track (simulated - not testing actual FFmpeg)
      Catalog.update_track_status(track1["id"], "ready")

      conn = build_conn() |> get("/admin/albums/#{album_id}/status")
      status = json_response(conn, 200)

      assert status["pending_count"] == 1
      assert status["ready_count"] == 1
      assert status["complete"] == false

      # Step 4: Upload second track
      Catalog.update_track_status(track2["id"], "ready")

      conn = build_conn() |> get("/admin/albums/#{album_id}/status")
      status = json_response(conn, 200)

      assert status["ready_count"] == 2
      assert status["complete"] == true
    end
  end
end
