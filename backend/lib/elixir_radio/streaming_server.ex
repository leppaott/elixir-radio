defmodule ElixirRadio.StreamingServer do
  use Plug.Router

  alias ElixirRadio.Catalog
  alias ElixirRadio.Catalog.{Segment, SegmentFile}
  alias ElixirRadio.StaticHeaders
  alias ElixirRadio.Workers.ProcessAudioJob
  alias ElixirRadio.SegmentCache

  require Logger

  plug(Plug.Logger)

  # CORS for development
  plug(:cors)

  # Parse multipart form data for uploads
  plug(Plug.Parsers,
    parsers: [:json, :multipart],
    pass: ["application/json", "multipart/form-data"],
    json_decoder: Jason,
    length: 52_428_800
  )

  plug(:match)
  plug(:dispatch)

  # Health check
  get "/health" do
    send_json(conn, 200, %{status: "ok"})
  end

  # === Genre Endpoints ===

  get "/api/genres" do
    after_id = conn.params["after_id"] && String.to_integer(conn.params["after_id"])
    per_page = String.to_integer(conn.params["per_page"] || "20")
    sort_by = String.to_existing_atom(conn.params["sort_by"] || "id")
    sort_order = String.to_existing_atom(conn.params["sort_order"] || "asc")

    result =
      Catalog.list_genres(
        after_id: after_id,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order
      )

    send_json(conn, 200, %{
      genres: result.items,
      pagination: %{
        per_page: result.per_page,
        has_more: result.has_more,
        next_cursor: result.next_cursor,
        sort_by: result.sort_by,
        sort_order: result.sort_order
      }
    })
  end

  get "/api/albums" do
    after_id = conn.params["after_id"] && String.to_integer(conn.params["after_id"])
    per_page = String.to_integer(conn.params["per_page"] || "20")
    sort_by = String.to_existing_atom(conn.params["sort_by"] || "id")
    sort_order = String.to_existing_atom(conn.params["sort_order"] || "desc")
    genre_id = conn.params["genre"] && String.to_integer(conn.params["genre"])
    artist_id = conn.params["artist"] && String.to_integer(conn.params["artist"])

    result =
      Catalog.list_albums(
        after_id: after_id,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order,
        genre_id: genre_id,
        artist_id: artist_id
      )

    albums =
      Enum.map(result.items, fn album ->
        tracks =
          (album.tracks || [])
          |> Enum.map(fn track ->
            %{
              id: track.id,
              title: track.title,
              track_number: track.track_number,
              duration_seconds: track.duration_seconds,
              upload_status: track.upload_status
            }
          end)

        %{
          id: album.id,
          title: album.title,
          release_year: album.release_year,
          cover_image_url: album.cover_image_url,
          description: album.description,
          artist: %{
            id: album.artist.id,
            name: album.artist.name
          },
          tracks: tracks
        }
      end)

    send_json(conn, 200, %{
      albums: albums,
      pagination: %{
        per_page: result.per_page,
        has_more: result.has_more,
        next_cursor: result.next_cursor,
        sort_by: result.sort_by,
        sort_order: result.sort_order
      }
    })
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

      # Add stream_url when segments are ready
      segment = Catalog.get_segment_by_track(id)

      response =
        if (track.upload_status == "ready" and segment) &&
             segment.processing_status == "completed" do
          Map.put(response, :stream_url, "/streams/tracks/#{track.id}/playlist.m3u8")
        else
          response
        end

      send_json(conn, 200, response)
    rescue
      Ecto.NoResultsError ->
        send_json(conn, 404, %{error: "Track not found"})
    end
  end

  # === Streaming Endpoints ===

  get "/streams/:genre" do
    after_id = conn.params["after_id"] && String.to_integer(conn.params["after_id"])
    per_page = String.to_integer(conn.params["per_page"] || "50")
    sort_by = String.to_existing_atom(conn.params["sort_by"] || "id")
    sort_order = String.to_existing_atom(conn.params["sort_order"] || "asc")

    case Catalog.get_genre_by_name(genre) do
      {:ok, genre_record} ->
        result =
          Catalog.list_tracks_by_genre(genre_record.id,
            after_id: after_id,
            per_page: per_page,
            sort_by: sort_by,
            sort_order: sort_order
          )

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
            pagination: %{
              per_page: result.per_page,
              has_more: result.has_more,
              next_cursor: result.next_cursor,
              sort_by: result.sort_by,
              sort_order: result.sort_order
            }
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
        |> StaticHeaders.apply()
        |> send_resp(200, playlist_data)

      %Segment{processing_status: status} ->
        conn
        |> StaticHeaders.apply()
        |> send_json(503, %{error: "Track is #{status}"})

      nil ->
        conn
        |> StaticHeaders.apply()
        |> send_json(404, %{error: "Playlist not found"})
    end
  end

  get "/streams/tracks/:track_id/segments/:segment_number" do
    segment_num =
      segment_number
      |> String.replace(".ts", "")
      |> String.to_integer()

    case Catalog.get_segment_by_track(track_id) do
      %Segment{id: segment_id, processing_status: "completed"} ->
        segment_data =
          case SegmentCache.get(segment_id, segment_num) do
            nil ->
              # Cache miss - fetch from DB
              case Catalog.get_segment_file(segment_id, segment_num) do
                nil ->
                  nil

                %SegmentFile{data: data} ->
                  # Store in cache with TTL
                  SegmentCache.put(segment_id, segment_num, data)
                  data
              end

            data ->
              # Cache hit
              data
          end

        case segment_data do
          nil ->
            conn
            |> StaticHeaders.apply()
            |> send_json(404, %{error: "Segment not found"})

          data ->
            conn
            |> StaticHeaders.apply()
            |> send_resp(200, data)
        end

      _ ->
        conn
        |> StaticHeaders.apply()
        |> send_json(404, %{error: "Segments not found"})
    end
  end

  # === Admin Endpoints ===

  post "/admin/artists" do
    case Catalog.create_artist(conn.body_params) do
      {:ok, artist} ->
        send_json(conn, 201, %{artist_id: artist.id})

      {:error, changeset} ->
        send_json(conn, 400, %{errors: format_errors(changeset)})
    end
  end

  post "/admin/albums" do
    album_attrs =
      Map.take(conn.body_params, [
        "title",
        "artist_id",
        "genre_id",
        "release_year",
        "cover_image_url",
        "description"
      ])

    tracks_attrs = Map.get(conn.body_params, "tracks", [])

    case Catalog.create_album_with_tracks(album_attrs, tracks_attrs) do
      {:ok, album} ->
        response = %{
          album_id: album.id,
          title: album.title,
          tracks:
            Enum.map(album.tracks, fn track ->
              %{
                id: track.id,
                title: track.title,
                track_number: track.track_number,
                upload_url: "/admin/tracks/#{track.id}/upload"
              }
            end)
        }

        send_json(conn, 201, response)

      {:error, changeset} ->
        send_json(conn, 400, %{errors: format_errors(changeset)})
    end
  end

  get "/admin/albums/:id/status" do
    case Catalog.get_album_status(id) do
      {:ok, status} ->
        send_json(conn, 200, status)

      {:error, :not_found} ->
        send_json(conn, 404, %{error: "Album not found"})
    end
  end

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

  # CORS helper
  defp cors(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "content-type, authorization")
  end
end
