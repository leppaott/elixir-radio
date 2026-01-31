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
        temp_dir = System.tmp_dir!()
        temp_input = Path.join(temp_dir, "input_#{track_id}_#{:rand.uniform(999_999)}")

        File.write!(temp_input, track.upload.file_data)
        Logger.info("Created temp file: #{temp_input}")

        result = process_audio(temp_input, track)

        File.rm(temp_input)

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
          {:error, Exception.message(error)}
      end
    end
  end

  defp process_audio(input_file, track) do
    temp_dir = System.tmp_dir!()
    output_dir = Path.join(temp_dir, "segments_#{track.id}_#{:rand.uniform(999_999)}")
    File.mkdir_p!(output_dir)

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

    # Suppress verbose FFmpeg stderr in test
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

        Enum.each(segment_files, fn {filename, index} ->
          segment_path = Path.join(output_dir, filename)
          segment_data = File.read!(segment_path)

          # Raw binary, no Base64 overhead
          %SegmentFile{}
          |> SegmentFile.changeset(%{
            segment_id: segment.id,
            index: index,
            data: segment_data
          })
          |> Repo.insert!()
        end)

        File.rm_rf!(output_dir)

        segment_count = length(segment_files)
        Logger.info("Generated #{segment_count} segments for track #{track.id}")
        {:ok, playlist_data, segment_count}

      {output, exit_code} ->
        File.rm_rf!(output_dir)
        error_msg = "FFmpeg failed with exit code #{exit_code}: #{output}"

        # Expected in tests, only log in production
        if Mix.env() != :test do
          Logger.error(error_msg)
        end

        {:error, error_msg}
    end
  end

  defp update_track_status(track, status) do
    track
    |> Ecto.Changeset.change(upload_status: status)
    |> Repo.update!()
  end
end
