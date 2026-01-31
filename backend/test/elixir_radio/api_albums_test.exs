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
      assert Enum.at(first["tracks"], 0)["stream_id"] == nil
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
  end
end
