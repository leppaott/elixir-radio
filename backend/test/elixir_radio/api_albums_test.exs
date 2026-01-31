defmodule ElixirRadio.ApiAlbumsTest do
  use ElixirRadio.ConnCase

  import ElixirRadio.Factory

  describe "GET /api/albums" do
    test "returns albums with tracks and no stream_id when not ready", %{conn: _conn} do
      genre = insert!(:genre)
      artist = insert!(:artist)

      album =
        insert!(:album, %{
          title: "Test Album",
          artist_id: artist.id,
          genre_id: genre.id
        })

      insert!(:track, %{
        title: "Track 1",
        album_id: album.id,
        track_number: 1,
        alt_track_number: "A1",
        upload_status: "pending"
      })

      conn = Plug.Test.conn(:get, "/api/albums")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert is_list(body["albums"]) and length(body["albums"]) >= 1

      first = Enum.find(body["albums"], &(&1["id"] == album.id))
      assert first
      assert is_list(first["tracks"]) and length(first["tracks"]) == 1
      track = Enum.at(first["tracks"], 0)
      assert track["stream_id"] == nil
      assert track["alt_track_number"] == "A1"
    end

    test "returns tracks with upload_status regardless of segment availability", %{conn: _conn} do
      genre = insert!(:genre)
      artist = insert!(:artist)

      album =
        insert!(:album, %{
          title: "Stream Album",
          artist_id: artist.id,
          genre_id: genre.id
        })

      track =
        insert!(:track, %{
          title: "Ready Track",
          album_id: album.id,
          track_number: 1,
          upload_status: "ready"
        })

      # Insert a segment marked completed for this track
      insert!(:segment, %{
        track_id: track.id,
        processing_status: "completed",
        playlist_data: "#EXTM3U"
      })

      conn = Plug.Test.conn(:get, "/api/albums")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)

      first = Enum.find(body["albums"], &(&1["id"] == album.id))
      assert first
      track_response = Enum.at(first["tracks"], 0)
      assert track_response["id"] == track.id
      assert track_response["upload_status"] == "ready"
      # stream_id is no longer included in album listings
      refute Map.has_key?(track_response, "stream_id")
    end

    test "filters albums by genre when genre query parameter is provided", %{conn: _conn} do
      genre1 = insert!(:genre, name: "Electronic")
      genre2 = insert!(:genre, name: "Jazz")
      artist = insert!(:artist)

      album1 =
        insert!(:album, %{
          title: "Electronic Album",
          artist_id: artist.id,
          genre_id: genre1.id
        })

      _album2 =
        insert!(:album, %{
          title: "Jazz Album",
          artist_id: artist.id,
          genre_id: genre2.id
        })

      conn = Plug.Test.conn(:get, "/api/albums?genre=#{genre1.id}")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert is_list(body["albums"])
      assert length(body["albums"]) == 1
      assert Enum.at(body["albums"], 0)["id"] == album1.id
      assert Enum.at(body["albums"], 0)["title"] == "Electronic Album"
    end

    test "filters albums by artist when artist query parameter is provided", %{conn: _conn} do
      genre = insert!(:genre)
      artist1 = insert!(:artist, name: "Artist One")
      artist2 = insert!(:artist, name: "Artist Two")

      album1 =
        insert!(:album, %{
          title: "Album by Artist One",
          artist_id: artist1.id,
          genre_id: genre.id
        })

      _album2 =
        insert!(:album, %{
          title: "Album by Artist Two",
          artist_id: artist2.id,
          genre_id: genre.id
        })

      conn = Plug.Test.conn(:get, "/api/albums?artist=#{artist1.id}")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert is_list(body["albums"])
      assert length(body["albums"]) == 1
      assert Enum.at(body["albums"], 0)["id"] == album1.id
      assert Enum.at(body["albums"], 0)["title"] == "Album by Artist One"
    end

    test "filters albums by both genre and artist when both query parameters provided", %{
      conn: _conn
    } do
      genre1 = insert!(:genre, name: "Electronic")
      genre2 = insert!(:genre, name: "Jazz")
      artist1 = insert!(:artist, name: "Artist One")
      artist2 = insert!(:artist, name: "Artist Two")

      album1 =
        insert!(:album, %{
          title: "Electronic by Artist One",
          artist_id: artist1.id,
          genre_id: genre1.id
        })

      _album2 =
        insert!(:album, %{
          title: "Jazz by Artist One",
          artist_id: artist1.id,
          genre_id: genre2.id
        })

      _album3 =
        insert!(:album, %{
          title: "Electronic by Artist Two",
          artist_id: artist2.id,
          genre_id: genre1.id
        })

      conn = Plug.Test.conn(:get, "/api/albums?genre=#{genre1.id}&artist=#{artist1.id}")
      conn = ElixirRadio.StreamingServer.call(conn, [])

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert is_list(body["albums"])
      assert length(body["albums"]) == 1
      assert Enum.at(body["albums"], 0)["id"] == album1.id
      assert Enum.at(body["albums"], 0)["title"] == "Electronic by Artist One"
    end
  end
end
