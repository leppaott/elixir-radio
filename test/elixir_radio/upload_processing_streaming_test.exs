defmodule ElixirRadio.UploadProcessingStreamingTest do
  use ElixirRadio.ConnCase, async: false

  import ElixirRadio.Factory
  import Ecto.Query

  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog

  @moduletag :integration

  # Path to real test audio file
  @test_audio_file Path.join(__DIR__, "../fixtures/file_example_MP3_2MG.mp3")

  describe "upload → processing → streaming integration" do
    setup do
      genre = insert!(:genre, name: "Electronic")
      artist = insert!(:artist)
      album = insert!(:album, genre: genre, artist: artist)
      track = insert!(:track, album: album, upload_status: "pending")

      %{genre: genre, track: track, album: album, artist: artist}
    end

    test "complete workflow: upload file, process in background, stream HLS", %{
      track: track,
      genre: genre
    } do
      # Step 1: Upload audio file
      conn =
        build_conn()
        |> put_req_header("content-type", "multipart/form-data; boundary=----WebKitFormBoundary")
        |> post("/admin/tracks/#{track.id}/upload", %{
          "audio_file" => %Plug.Upload{
            path: @test_audio_file,
            filename: "test_track.mp3",
            content_type: "audio/mpeg"
          }
        })

      assert json_response(conn, 202) == %{
               "message" => "Upload received, processing queued",
               "track_id" => to_string(track.id),
               "status" => "pending"
             }

      # Verify upload was created
      track = Repo.preload(track, :upload, force: true)
      assert track.upload != nil
      assert track.upload.mime_type == "audio/mpeg"
      assert track.upload.original_filename == "test_track.mp3"

      # Step 2: Process the Oban job
      assert_oban_job_processed(track.id)

      # Step 3: Verify track is ready
      conn = build_conn() |> get("/admin/tracks/#{track.id}/status")
      response = json_response(conn, 200)

      assert response["track_id"] == track.id
      assert response["upload_status"] == "ready"
      assert response["processing_status"] == "completed"
      assert response["ready_to_stream"] == true
      assert response["processing_error"] == nil

      # Step 4: Verify track appears in genre stream
      conn = build_conn() |> get("/streams/#{genre.name}")
      response = json_response(conn, 200)

      assert response["genre"] == genre.name
      assert response["total_count"] == 1
      assert length(response["tracks"]) == 1

      track_in_stream = hd(response["tracks"])
      assert track_in_stream["track_id"] == track.id
      assert track_in_stream["playlist_url"] == "/streams/tracks/#{track.id}/playlist.m3u8"

      # Step 5: Verify HLS playlist endpoint
      conn = build_conn() |> get("/streams/tracks/#{track.id}/playlist.m3u8")
      assert conn.status == 200

      # Verify content-type header (may include charset)
      [content_type] = get_resp_header(conn, "content-type")
      assert content_type =~ "application/vnd.apple.mpegurl"

      playlist_content = conn.resp_body
      assert playlist_content =~ "#EXTM3U"
      assert playlist_content =~ "#EXT-X-VERSION"
      assert playlist_content =~ "#EXT-X-TARGETDURATION"
      # Should have segments with correct relative paths
      assert playlist_content =~ "segments/0.ts"
      assert playlist_content =~ "segments/1.ts"

      # Step 6: Verify segment endpoints work and return binary data
      conn = build_conn() |> get("/streams/tracks/#{track.id}/segments/0.ts")
      assert conn.status == 200
      [content_type] = get_resp_header(conn, "content-type")
      assert content_type =~ "video/mp2t"
      assert byte_size(conn.resp_body) > 0

      # Verify multiple segments can be fetched
      conn = build_conn() |> get("/streams/tracks/#{track.id}/segments/1.ts")
      assert conn.status == 200
      assert byte_size(conn.resp_body) > 0

      # Verify non-existent segment returns 404
      conn = build_conn() |> get("/streams/tracks/#{track.id}/segments/999.ts")
      assert conn.status == 404
    end

    test "upload fails when track does not exist" do
      conn =
        build_conn()
        |> post("/admin/tracks/999999/upload", %{
          "audio_file" => %Plug.Upload{
            path: @test_audio_file,
            filename: "test.mp3",
            content_type: "audio/mpeg"
          }
        })

      assert json_response(conn, 404)["error"] == "Track not found"
    end

    test "upload succeeds with valid file size", %{track: track} do
      # This test verifies the endpoint handles file uploads correctly
      # Our test file is 2MB which is well under the 50MB limit
      conn =
        build_conn()
        |> post("/admin/tracks/#{track.id}/upload", %{
          "audio_file" => %Plug.Upload{
            path: @test_audio_file,
            filename: "test.mp3",
            content_type: "audio/mpeg"
          }
        })

      # Should succeed since file is under limit
      assert conn.status == 202
    end

    test "streaming endpoints return 404 when track not ready", %{track: track} do
      # Track exists but is not processed yet
      conn = build_conn() |> get("/streams/tracks/#{track.id}/playlist.m3u8")
      assert json_response(conn, 404)["error"] == "Playlist not found"

      conn = build_conn() |> get("/streams/tracks/#{track.id}/segments/0.ts")
      assert json_response(conn, 404)["error"] == "Segments not found"
    end

    test "genre stream returns empty when no ready tracks", %{genre: genre} do
      conn = build_conn() |> get("/streams/#{genre.name}")
      response = json_response(conn, 404)

      assert response["error"] == "Genre not found or no tracks available"
    end

    test "multiple uploads to same track replace previous upload", %{track: track} do
      # First upload
      conn =
        build_conn()
        |> post("/admin/tracks/#{track.id}/upload", %{
          "audio_file" => %Plug.Upload{
            path: @test_audio_file,
            filename: "first.mp3",
            content_type: "audio/mpeg"
          }
        })

      assert json_response(conn, 202)

      # Process first upload (will fail due to FFmpeg but upload should succeed)
      perform_oban_job(track.id)

      # Second upload (replace) - should also succeed
      conn =
        build_conn()
        |> post("/admin/tracks/#{track.id}/upload", %{
          "audio_file" => %Plug.Upload{
            path: @test_audio_file,
            filename: "second.mp3",
            content_type: "audio/mpeg"
          }
        })

      assert json_response(conn, 202)

      # Verify latest upload filename
      track = Repo.preload(track, :upload, force: true)
      assert track.upload.original_filename == "second.mp3"
    end

    test "processing handles FFmpeg failures gracefully", %{track: track} do
      # Upload invalid audio data
      invalid_file = Path.join(System.tmp_dir!(), "invalid_#{:rand.uniform(999_999)}.mp3")
      File.write!(invalid_file, "not valid audio data at all")

      conn =
        build_conn()
        |> post("/admin/tracks/#{track.id}/upload", %{
          "audio_file" => %Plug.Upload{
            path: invalid_file,
            filename: "invalid.mp3",
            content_type: "audio/mpeg"
          }
        })

      File.rm(invalid_file)
      assert json_response(conn, 202)

      # Process job (will fail due to invalid audio)
      perform_oban_job(track.id)

      # Check status shows failure
      conn = build_conn() |> get("/admin/tracks/#{track.id}/status")
      response = json_response(conn, 200)

      assert response["upload_status"] == "failed"
      assert response["processing_status"] == "failed"
      assert response["ready_to_stream"] == false
      assert response["processing_error"] != nil
    end

    test "segments are correctly base64 encoded and decoded", %{track: track} do
      # Upload and process
      conn =
        build_conn()
        |> post("/admin/tracks/#{track.id}/upload", %{
          "audio_file" => %Plug.Upload{
            path: @test_audio_file,
            filename: "test.mp3",
            content_type: "audio/mpeg"
          }
        })

      assert json_response(conn, 202)
      assert_oban_job_processed(track.id)

      # Get segment directly from database
      segment = Catalog.get_segment_by_track(track.id)
      assert segment != nil
      assert is_map(segment.segment_files)

      # Verify segment data is base64 encoded in database
      first_segment = Map.get(segment.segment_files, "0")
      assert is_binary(first_segment)
      # Check it's valid base64 (will raise if not)
      decoded = Base.decode64!(first_segment)
      assert is_binary(decoded)
      assert byte_size(decoded) > 0

      # Verify streaming decodes it properly
      conn = build_conn() |> get("/streams/tracks/#{track.id}/segments/0.ts")
      assert conn.status == 200
      # Should return decoded binary, not base64 string
      assert conn.resp_body == decoded
    end
  end

  # Helper to process Oban job in test
  defp assert_oban_job_processed(track_id) do
    # In test mode with Oban testing: :manual, we need to manually perform jobs
    result = perform_oban_job(track_id)

    assert result == :ok,
           "Expected Oban job to process successfully, got: #{inspect(result)}"

    # Wait a bit for any async operations
    Process.sleep(100)

    # Verify track status changed
    track = Repo.get!(Catalog.Track, track_id)
    assert track.upload_status in ["ready", "processing", "failed"]
  end

  defp perform_oban_job(track_id) do
    # Get the most recent job for this track
    track_id_str = to_string(track_id)

    job =
      Repo.one(
        from(j in Oban.Job,
          where: fragment("args->>'track_id' = ?", ^track_id_str),
          order_by: [desc: j.id],
          limit: 1
        )
      )

    if job do
      # Manually perform the job
      case Oban.drain_queue(queue: :audio_processing, with_safety: false) do
        %{success: success} when success > 0 -> :ok
        _ -> {:error, :job_failed}
      end
    else
      {:error, :no_job_found}
    end
  end
end
