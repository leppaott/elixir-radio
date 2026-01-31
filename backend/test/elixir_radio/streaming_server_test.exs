defmodule ElixirRadio.StreamingServerTest do
  use ElixirRadio.ConnCase
  import ElixirRadio.Factory

  describe "GET /api/genres" do
    test "returns empty list when no genres exist", %{conn: _conn} do
      conn = Plug.Test.conn(:get, "/api/genres")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body["genres"] == []
    end

    test "returns all genres", %{conn: _conn} do
      _genre1 = insert!(:genre, name: "Electronic")
      _genre2 = insert!(:genre, name: "Jazz")

      conn = Plug.Test.conn(:get, "/api/genres")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)

      assert length(body["genres"]) == 2
      assert Enum.any?(body["genres"], &(&1["name"] == "Electronic"))
      assert Enum.any?(body["genres"], &(&1["name"] == "Jazz"))
    end
  end

  describe "GET /api/albums/:id" do
    test "returns 404 when album doesn't exist", %{conn: _conn} do
      conn = Plug.Test.conn(:get, "/api/albums/999")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 404
    end

    test "returns album with tracks and artist", %{conn: _conn} do
      genre = insert!(:genre)
      artist = insert!(:artist, name: "Test Artist")

      album =
        insert!(:album, %{
          title: "Test Album",
          artist_id: artist.id,
          genre_id: genre.id
        })

      _track1 =
        insert!(:track, %{
          title: "Track 1",
          album_id: album.id,
          track_number: 1
        })

      _track2 =
        insert!(:track, %{
          title: "Track 2",
          album_id: album.id,
          track_number: 2
        })

      conn = Plug.Test.conn(:get, "/api/albums/#{album.id}")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)

      assert body["id"] == album.id
      assert body["title"] == "Test Album"
      assert body["artist"]["name"] == "Test Artist"
      assert length(body["tracks"]) == 2
      assert Enum.any?(body["tracks"], &(&1["title"] == "Track 1"))
      assert Enum.any?(body["tracks"], &(&1["title"] == "Track 2"))
    end
  end

  describe "GET /streams/:genre_name" do
    test "returns 404 when genre doesn't exist", %{conn: _conn} do
      conn = Plug.Test.conn(:get, "/streams/NonExistent")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 404
    end

    test "returns 404 when genre has no tracks", %{conn: _conn} do
      insert!(:genre, name: "Electronic")

      conn = Plug.Test.conn(:get, "/streams/Electronic")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 404
    end

    test "returns paginated tracks for genre with ready segments", %{conn: _conn} do
      genre = insert!(:genre, name: "Electronic")
      artist = insert!(:artist)

      album =
        insert!(:album, %{
          artist_id: artist.id,
          genre_id: genre.id
        })

      # Track with ready segment
      _track1 =
        insert!(:track, %{
          title: "Track 1",
          album_id: album.id,
          track_number: 1,
          upload_status: "ready"
        })

      # Track without segment (should be excluded)
      _track2 =
        insert!(:track, %{
          title: "Track 2",
          album_id: album.id,
          track_number: 2,
          upload_status: "pending"
        })

      conn = Plug.Test.conn(:get, "/streams/Electronic")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)

      assert body["genre"] == "Electronic"
      assert is_list(body["tracks"])
      assert body["page"] == 1
      assert body["total_pages"] >= 1
    end

    test "supports pagination", %{conn: _conn} do
      genre = insert!(:genre, name: "Electronic")
      artist = insert!(:artist)

      album =
        insert!(:album, %{
          artist_id: artist.id,
          genre_id: genre.id
        })

      # Create multiple tracks
      for i <- 1..3 do
        insert!(:track, %{
          title: "Track #{i}",
          album_id: album.id,
          track_number: i,
          upload_status: "ready"
        })
      end

      # Test page 1
      conn = Plug.Test.conn(:get, "/streams/Electronic?page=1&per_page=2")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)

      assert body["page"] == 1
      assert body["per_page"] == 2
    end
  end

  describe "GET /health" do
    test "returns ok status", %{conn: _conn} do
      conn = Plug.Test.conn(:get, "/health")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
    end
  end

  describe "GET /api/tracks/:id" do
    test "returns 404 when track doesn't exist", %{conn: _conn} do
      conn = Plug.Test.conn(:get, "/api/tracks/999")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 404
    end

    test "returns track details with album and artist", %{conn: _conn} do
      genre = insert!(:genre)
      artist = insert!(:artist, name: "Artist Name")

      album =
        insert!(:album, %{
          title: "Album Title",
          artist_id: artist.id,
          genre_id: genre.id
        })

      track =
        insert!(:track, %{
          title: "Track Title",
          album_id: album.id,
          track_number: 1,
          duration_seconds: 240
        })

      conn = Plug.Test.conn(:get, "/api/tracks/#{track.id}")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)

      assert body["id"] == track.id
      assert body["title"] == "Track Title"
      assert body["album"]["title"] == "Album Title"
      assert body["album"]["artist"]["name"] == "Artist Name"
    end
  end

  describe "POST /admin/tracks/:id/upload" do
    test "returns 404 when track doesn't exist", %{conn: _conn} do
      conn = Plug.Test.conn(:post, "/admin/tracks/999/upload")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 404
    end

    test "returns error when no file uploaded", %{conn: _conn} do
      genre = insert!(:genre)
      artist = insert!(:artist)

      album =
        insert!(:album, %{
          artist_id: artist.id,
          genre_id: genre.id
        })

      track =
        insert!(:track, %{
          album_id: album.id,
          track_number: 1
        })

      conn = Plug.Test.conn(:post, "/admin/tracks/#{track.id}/upload")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 400
      body = Jason.decode!(conn.resp_body)
      assert body["error"] =~ "audio_file"
    end
  end
end
