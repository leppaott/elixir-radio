defmodule ElixirRadio.Workers.ProcessAudioJob do
  @moduledoc """
  Background job to process uploaded audio files and generate HLS segments.
  Stores all segments in the database as bytea.
  """

  use Oban.Worker,
    queue: :audio_processing,
    max_attempts: 3

  require Logger

  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog.{Track, Segment, SegmentFile}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"track_id" => track_id}}) do
    # Oban stores args as strings
    track_id = String.to_integer(track_id)
    Logger.info("Starting audio processing for track #{track_id}")

    track = Repo.get!(Track, track_id) |> Repo.preload([:upload, :segment])

    if !track.upload do
      {:error, "No upload found for track #{track_id}"}
    else
      update_track_status(track, :processing)

      # Query DB in case of retry
      segment =
        Repo.get_by(Segment, track_id: track_id) ||
          Repo.insert!(%Segment{
            track_id: track_id,
            processing_status: :pending,
            playlist_data: <<>>
          })

      segment =
        Ecto.Changeset.change(segment, processing_status: :processing)
        |> Repo.update!()

      try do
        temp_dir =
          Path.join(System.tmp_dir!(), "upload_#{track_id}_#{System.unique_integer([:positive])}")

        File.mkdir_p!(temp_dir)

        temp_input = Path.join(temp_dir, "raw_#{track_id}")

        File.write!(temp_input, track.upload.file_data)

        result = process_audio(temp_dir, temp_input, track)

        File.rm_rf!(temp_dir)

        case result do
          {:ok, playlist_data, segment_count} ->
            segment
            |> Segment.changeset(%{
              playlist_data: playlist_data,
              processing_status: :completed
            })
            |> Repo.update!()

            update_track_status(track, :ready)

            Logger.info(
              "Successfully processed track #{track_id}, stored #{segment_count} segments"
            )

            :ok

          {:error, reason} ->
            segment
            |> Ecto.Changeset.change(processing_status: :failed, processing_error: reason)
            |> Repo.update!()

            update_track_status(track, :failed)

            {:error, reason}
        end
      rescue
        error ->
          Logger.error("Error processing track #{track_id}: #{inspect(error)}")

          segment
          |> Ecto.Changeset.change(
            processing_status: :failed,
            processing_error: Exception.message(error)
          )
          |> Repo.update!()

          update_track_status(track, :failed)

          Logger.error("Processing crashed for track #{track_id}: #{inspect(error)}")

          {:error, Exception.message(error)}
      end
    end
  end

  defp process_audio(output_dir, input_file, track) do
    playlist_file = Path.join(output_dir, "playlist.m3u8")
    segment_pattern = Path.join(output_dir, "segment%d.ts")

    sample_duration = track.sample_duration || 120
    segment_time = 10

    ffmpeg_args = [
      "-i",
      input_file,
      "-t",
      to_string(sample_duration),
      "-vn",
      "-ac",
      "2",
      "-acodec",
      "aac",
      "-b:a",
      "128k",
      "-f",
      "segment",
      "-segment_format",
      "mpegts",
      "-segment_time",
      to_string(segment_time),
      "-segment_list",
      playlist_file,
      segment_pattern
    ]

    Logger.info("Running ffmpeg for track #{track.id}")

    result =
      if Mix.env() == :test do
        # Redirect stderr to /dev/null in test mode
        System.cmd("sh", [
          "-c",
          "ffmpeg #{Enum.join(Enum.map(ffmpeg_args, &"'#{&1}'"), " ")} 2>/dev/null"
        ])
      else
        System.cmd("ffmpeg", ffmpeg_args, stderr_to_stdout: true)
      end

    case result do
      {_output, 0} ->
        playlist_data =
          File.read!(playlist_file)
          |> String.replace(~r/segment(\d+)\.ts/, "segments/\\1.ts")

        segment_files =
          File.ls!(output_dir)
          |> Enum.filter(&String.ends_with?(&1, ".ts"))
          |> Enum.sort()
          |> Enum.with_index()

        segment = Repo.get_by!(Segment, track_id: track.id)

        now = NaiveDateTime.utc_now(:second)

        rows =
          Enum.map(segment_files, fn {filename, index} ->
            segment_path = Path.join(output_dir, filename)
            segment_data = File.read!(segment_path)

            %{
              segment_id: segment.id,
              index: index,
              data: segment_data,
              inserted_at: now,
              updated_at: now
            }
          end)

        {count, _} = Repo.insert_all(SegmentFile, rows)

        {:ok, playlist_data, count}

      {output, exit_code} ->
        error_msg = "FFmpeg failed with exit code #{exit_code}: #{output}"
        {:error, error_msg}
    end
  end

  defp update_track_status(track, status) do
    track
    |> Ecto.Changeset.change(upload_status: status)
    |> Repo.update!()
  end
end
