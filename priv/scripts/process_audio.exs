#!/usr/bin/env elixir

# Process an audio file and generate HLS segments for a track
# Usage: mix run priv/scripts/process_audio.exs <track_id> <audio_file_path> [options]
# Options:
#   --sample-duration <seconds>  Duration of the sample (default: 60)
#   --start-time <seconds>       Start time of the sample (default: 0)

alias ElixirRadio.Repo
alias ElixirRadio.Catalog
alias ElixirRadio.AudioProcessor

require Logger

# Start the application
Application.ensure_all_started(:elixir_radio)

# Parse arguments
[track_id_str, audio_file | opts] = System.argv()

if !File.exists?(audio_file) do
  Logger.error("Audio file not found: #{audio_file}")
  System.halt(1)
end

track_id = String.to_integer(track_id_str)

# Parse options
{parsed_opts, _, _} =
  OptionParser.parse(opts,
    strict: [sample_duration: :integer, start_time: :integer],
    aliases: [d: :sample_duration, s: :start_time]
  )

# Validate ffmpeg
case AudioProcessor.validate_ffmpeg() do
  {:ok, ffmpeg_path} ->
    Logger.info("Found ffmpeg at: #{ffmpeg_path}")

  {:error, msg} ->
    Logger.error(msg)
    System.halt(1)
end

# Get track
track = Catalog.get_track!(track_id)
Logger.info("Processing track: #{track.title}")

# Process audio
case AudioProcessor.process_track(track_id, audio_file, parsed_opts) do
  {:ok, %{stream_id: stream_id, playlist_path: playlist_path}} ->
    # Update track with stream_id
    {:ok, updated_track} =
      Catalog.create_track(%{
        title: track.title,
        album_id: track.album_id,
        track_number: track.track_number,
        duration_seconds: track.duration_seconds,
        sample_duration: Keyword.get(parsed_opts, :sample_duration, 60),
        file_path: audio_file,
        stream_id: stream_id
      })

    Logger.info("Successfully processed track!")
    Logger.info("Stream ID: #{stream_id}")
    Logger.info("Playlist: #{playlist_path}")
    Logger.info("Stream URL: #{AudioProcessor.get_stream_url(stream_id)}")

  {:error, reason} ->
    Logger.error("Failed to process track: #{reason}")
    System.halt(1)
end
