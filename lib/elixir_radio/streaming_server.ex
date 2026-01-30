defmodule ElixirRadio.StreamingServer do
  use Plug.Router

  alias ElixirRadio.Catalog
  alias ElixirRadio.Catalog.Segment
  alias ElixirRadio.Workers.ProcessAudioJob

  require Logger

  plug(Plug.Logger)

  # Parse multipart form data for uploads
  plug(Plug.Parsers,
    parsers: [:json, :multipart],
    pass: ["application/json", "multipart/form-data"],
    json_decoder: Jason,
    length: 52_428_800
  )

  plug(:match)
  plug(:dispatch)

  # Root endpoint
  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <h1>🎵 Elixir Radio - Vinyl Store Streaming</h1>
    <h2>API Endpoints:</h2>
    <h3>Genres</h3>
    <ul>
      <li>GET /api/genres - List all genres</li>
      <li>GET /api/genres/:id/albums?page=1&per_page=20 - Albums by genre</li>
    </ul>
    <h3>Albums & Artists</h3>
    <ul>
      <li>GET /api/albums/:id - Get album with tracks</li>
      <li>GET /api/artists/:id/albums?page=1&per_page=20 - Albums by artist</li>
    </ul>
    <h3>Tracks</h3>
    <ul>
      <li>GET /api/tracks/:id - Get track details</li>
    </ul>
    <h3>Streaming</h3>
    <ul>
      <li>GET /streams/:genre?page=1&per_page=50 - Get streamable tracks by genre</li>
      <li>GET /streams/tracks/:track_id/playlist.m3u8 - HLS playlist</li>
      <li>GET /streams/tracks/:track_id/segments/:number.ts - HLS segment</li>
    </ul>
    <h3>Admin</h3>
    <ul>
      <li>POST /admin/tracks - Create track</li>
      <li>POST /admin/tracks/:id/upload - Upload audio file</li>
      <li>GET /admin/tracks/:id/status - Check processing status</li>
    </ul>
    """)
  end

  # Health check
  get "/health" do
    send_json(conn, 200, %{status: "ok"})
  end

  # === Genre Endpoints ===

  get "/api/genres" do
    genres = Catalog.list_genres()
    send_json(conn, 200, %{genres: genres})
  end

  get "/api/genres/:id/albums" do
    page = String.to_integer(conn.params["page"] || "1")
    per_page = String.to_integer(conn.params["per_page"] || "20")

    try do
      result = Catalog.list_albums_by_genre(id, page: page, per_page: per_page)

      send_json(conn, 200, %{
        albums: result.items,
        pagination: %{
          page: result.page,
          per_page: result.per_page,
          total_pages: result.total_pages,
          total_count: result.total_count
        }
      })
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Genre not found"})
    end
  end

  # === Album Endpoints ===

  get "/api/albums/:id" do
    try do
      album = Catalog.get_album!(id)

      response = %{
        id: album.id,
        title: album.title,
        release_year: album.release_year,
        cover_image_url: album.cover_image_url,
        description: album.description,
        artist: %{
          id: album.artist.id,
          name: album.artist.name,
          bio: album.artist.bio,
          image_url: album.artist.image_url
        },
        tracks:
          Enum.map(album.tracks, fn track ->
            %{
              id: track.id,
              title: track.title,
              track_number: track.track_number,
              duration_seconds: track.duration_seconds,
              upload_status: track.upload_status
            }
          end),
        inserted_at: album.inserted_at,
        updated_at: album.updated_at
      }

      send_json(conn, 200, response)
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Album not found"})
    end
  end

  # === Artist Endpoints ===

  get "/api/artists/:id/albums" do
    page = String.to_integer(conn.params["page"] || "1")
    per_page = String.to_integer(conn.params["per_page"] || "20")

    try do
      artist = Catalog.get_artist!(id)
      result = Catalog.list_albums_by_artist(id, page: page, per_page: per_page)

      send_json(conn, 200, %{
        artist: artist,
        albums: result.items,
        pagination: %{
          page: result.page,
          per_page: result.per_page,
          total_pages: result.total_pages,
          total_count: result.total_count
        }
      })
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Artist not found"})
    end
  end

  # === Track Endpoints ===

  get "/api/tracks/:id" do
    try do
      track = Catalog.get_track!(id)

      response = %{
        id: track.id,
        title: track.title,
        track_number: track.track_number,
        duration_seconds: track.duration_seconds,
        sample_duration: track.sample_duration,
        upload_status: track.upload_status,
        album: %{
          id: track.album.id,
          title: track.album.title,
          release_year: track.album.release_year,
          cover_image_url: track.album.cover_image_url,
          artist: %{
            id: track.album.artist.id,
            name: track.album.artist.name,
            bio: track.album.artist.bio,
            image_url: track.album.artist.image_url
          }
        },
        inserted_at: track.inserted_at,
        updated_at: track.updated_at
      }

      send_json(conn, 200, response)
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Track not found"})
    end
  end

  # === Streaming Endpoints ===

  get "/streams/:genre" do
    page = String.to_integer(conn.params["page"] || "1")
    per_page = String.to_integer(conn.params["per_page"] || "50")

    case Catalog.get_genre_by_name(genre) do
      {:ok, genre_record} ->
        result = Catalog.list_tracks_by_genre(genre_record.id, page: page, per_page: per_page)

        if Enum.empty?(result.items) do
          send_json(conn, 404, %{error: "Genre not found or no tracks available"})
        else
          streams =
            Enum.map(result.items, fn track ->
              %{
                track_id: track.id,
                title: track.title,
                artist_name: track.album.artist.name,
                album_title: track.album.title,
                playlist_url: "/streams/tracks/#{track.id}/playlist.m3u8",
                sample_duration: track.sample_duration,
                track_number: track.track_number
              }
            end)

          send_json(conn, 200, %{
            genre: genre_record.name,
            tracks: streams,
            page: result.page,
            per_page: result.per_page,
            total_pages: result.total_pages,
            total_count: result.total_count
          })
        end

      {:error, :not_found} ->
        send_json(conn, 404, %{error: "Genre not found or no tracks available"})
    end
  end

  get "/streams/tracks/:track_id/playlist.m3u8" do
    case Catalog.get_segment_by_track(track_id) do
      %Segment{playlist_data: playlist_data, processing_status: "completed"} ->
        conn
        |> put_resp_content_type("application/vnd.apple.mpegurl")
        |> put_resp_header("access-control-allow-origin", "*")
        |> send_resp(200, playlist_data)

      %Segment{processing_status: status} ->
        send_json(conn, 503, %{error: "Track is #{status}"})

      nil ->
        send_json(conn, 404, %{error: "Playlist not found"})
    end
  end

  get "/streams/tracks/:track_id/segments/:segment_number" do
    segment_num = segment_number |> String.replace(".ts", "")

    case Catalog.get_segment_by_track(track_id) do
      %Segment{segment_files: files, processing_status: "completed"} ->
        case Map.get(files, segment_num) do
          nil ->
            send_json(conn, 404, %{error: "Segment not found"})

          base64_segment_data ->
            # Decode base64-encoded segment data
            segment_data = Base.decode64!(base64_segment_data)

            conn
            |> put_resp_content_type("video/mp2t")
            |> put_resp_header("access-control-allow-origin", "*")
            |> send_resp(200, segment_data)
        end

      _ ->
        send_json(conn, 404, %{error: "Segments not found"})
    end
  end

  # === Admin Endpoints ===

  post "/admin/tracks" do
    case Catalog.create_track(conn.body_params) do
      {:ok, track} ->
        send_json(conn, 201, %{track: track})

      {:error, changeset} ->
        send_json(conn, 400, %{errors: format_errors(changeset)})
    end
  end

  post "/admin/tracks/:id/upload" do
    try do
      _track = Catalog.get_track!(id)

      case conn.body_params do
        %{"audio_file" => %Plug.Upload{} = upload} ->
          handle_upload(conn, id, upload)

        _ ->
          send_json(conn, 400, %{error: "No audio_file provided"})
      end
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Track not found"})
    end
  end

  get "/admin/tracks/:id/status" do
    try do
      track = Catalog.get_track!(id)
      segment = Catalog.get_segment_by_track(id)

      status_response = %{
        track_id: track.id,
        upload_status: track.upload_status,
        processing_status: segment && segment.processing_status,
        processing_error: segment && segment.processing_error,
        ready_to_stream:
          track.upload_status == "ready" && segment && segment.processing_status == "completed"
      }

      send_json(conn, 200, status_response)
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Track not found"})
    end
  end

  # === Helpers ===

  defp handle_upload(conn, track_id, %Plug.Upload{
         path: path,
         filename: filename,
         content_type: content_type
       }) do
    file_data = File.read!(path)
    file_size = byte_size(file_data)

    if file_size > 52_428_800 do
      send_json(conn, 400, %{error: "File too large (max 50MB)"})
    else
      case Catalog.create_or_replace_upload(%{
             track_id: track_id,
             original_filename: filename,
             file_data: file_data,
             mime_type: content_type,
             file_size: file_size
           }) do
        {:ok, _upload} ->
          # Enqueue background job
          job_result =
            %{track_id: track_id}
            |> ProcessAudioJob.new()
            |> Oban.insert()

          require Logger

          case job_result do
            {:ok, job} ->
              Logger.info("Oban job queued successfully: #{inspect(job)}")

            {:error, reason} ->
              Logger.error("Failed to queue Oban job: #{inspect(reason)}")
          end

          send_json(conn, 202, %{
            message: "Upload received, processing queued",
            track_id: track_id,
            status: "pending"
          })

        {:error, changeset} ->
          send_json(conn, 400, %{errors: format_errors(changeset)})
      end
    end
  end

  defp send_json(conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  # Catch-all
  match _ do
    send_json(conn, 404, %{error: "Not found"})
  end
end
