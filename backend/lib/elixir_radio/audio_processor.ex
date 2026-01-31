defmodule ElixirRadio.AudioProcessor do
  @moduledoc """
  Handles audio file processing and HLS segment generation.
  """

  require Logger

  @data_dir "/data"
  @segment_duration 10

  @doc """
  Processes an audio file and generates HLS segments for a track.

  Options:
  - :sample_duration - Duration in seconds for the sample (default: 60)
  - :segment_duration - Duration of each segment in seconds (default: 10)
  - :start_time - Start time for the sample in seconds (default: 0)
  """
  def process_track(track_id, input_file, opts \\ []) do
    sample_duration = Keyword.get(opts, :sample_duration, 60)
    segment_duration = Keyword.get(opts, :segment_duration, @segment_duration)
    start_time = Keyword.get(opts, :start_time, 0)

    stream_id = generate_stream_id(track_id)
    stream_dir = Path.join(@data_dir, stream_id)
    segments_dir = Path.join(stream_dir, "segments")
    playlist_file = Path.join(stream_dir, "audio_pl.m3u8")

    # Create directories
    File.mkdir_p!(segments_dir)

    # Generate HLS segments using ffmpeg
    segment_pattern = Path.join(segments_dir, "segment%d.ts")

    ffmpeg_args = [
      "-i",
      input_file,
      "-ss",
      to_string(start_time),
      "-t",
      to_string(sample_duration),
      "-vn",
      "-ac",
      "2",
      "-acodec",
      "aac",
      "-f",
      "segment",
      "-segment_format",
      "mpegts",
      "-segment_time",
      to_string(segment_duration),
      "-segment_list",
      playlist_file,
      segment_pattern
    ]

    Logger.info("Processing track #{track_id} with ffmpeg: #{input_file}")

    case System.cmd("ffmpeg", ffmpeg_args, stderr_to_stdout: true) do
      {_output, 0} ->
        Logger.info("Successfully processed track #{track_id}")
        {:ok, %{stream_id: stream_id, playlist_path: playlist_file, segments_dir: segments_dir}}

      {output, exit_code} ->
        Logger.error("Failed to process track #{track_id}: #{output}")
        {:error, "FFmpeg failed with exit code #{exit_code}"}
    end
  end

  @doc """
  Generates a unique stream ID for a track.
  """
  def generate_stream_id(track_id) do
    "track_#{track_id}_#{:erlang.system_time(:second)}"
  end

  @doc """
  Gets the URL path for streaming a track.
  """
  def get_stream_url(stream_id) do
    "/streams/#{stream_id}/audio_pl.m3u8"
  end

  @doc """
  Cleans up segments for a given stream ID.
  """
  def cleanup_stream(stream_id) do
    stream_dir = Path.join(@data_dir, stream_id)

    if File.exists?(stream_dir) do
      File.rm_rf!(stream_dir)
      Logger.info("Cleaned up stream directory: #{stream_dir}")
      :ok
    else
      {:error, :not_found}
    end
  end

  @doc """
  Validates that ffmpeg is available.
  """
  def validate_ffmpeg do
    case System.cmd("which", ["ffmpeg"], stderr_to_stdout: true) do
      {path, 0} ->
        {:ok, String.trim(path)}

      _ ->
        {:error, "ffmpeg not found in PATH"}
    end
  end
end
