#!/usr/bin/env elixir

# Batch process multiple audio files for an album
# Usage: mix run priv/scripts/batch_process.exs <album_id> <audio_directory> [options]
# Options:
#   --sample-duration <seconds>  Duration of the sample for all tracks (default: 60)
#   --start-time <seconds>       Start time of the sample (default: 0)
#   --pattern <glob>             File pattern to match (default: "*.{flac,mp3,wav,m4a}")

alias ElixirRadio.Repo
alias ElixirRadio.Catalog
alias ElixirRadio.AudioProcessor

require Logger

# Start the application
Application.ensure_all_started(:elixir_radio)

# Parse arguments
[album_id_str, audio_dir | opts] = System.argv()

if !File.dir?(audio_dir) do
  Logger.error("Directory not found: #{audio_dir}")
  System.halt(1)
end

album_id = String.to_integer(album_id_str)

# Parse options
{parsed_opts, _, _} =
  OptionParser.parse(opts,
    strict: [sample_duration: :integer, start_time: :integer, pattern: :string],
    aliases: [d: :sample_duration, s: :start_time, p: :pattern]
  )

pattern = Keyword.get(parsed_opts, :pattern, "*.{flac,mp3,wav,m4a}")

# Validate ffmpeg
case AudioProcessor.validate_ffmpeg() do
  {:ok, ffmpeg_path} ->
    Logger.info("Found ffmpeg at: #{ffmpeg_path}")

  {:error, msg} ->
    Logger.error(msg)
    System.halt(1)
end

# Get album and tracks
album = Catalog.get_album!(album_id)
tracks = Catalog.get_tracks_by_album(album_id)

Logger.info("Processing album: #{album.title}")
Logger.info("Found #{length(tracks)} tracks")

# Find audio files
audio_files =
  Path.wildcard(Path.join(audio_dir, pattern))
  |> Enum.sort()

Logger.info("Found #{length(audio_files)} audio files")

if length(audio_files) < length(tracks) do
  Logger.warning("Warning: More tracks than audio files!")
end

# Process each track
Enum.zip(tracks, audio_files)
|> Enum.each(fn {track, audio_file} ->
  Logger.info("\nProcessing: #{track.title} <- #{Path.basename(audio_file)}")

  case AudioProcessor.process_track(track.id, audio_file, parsed_opts) do
    {:ok, %{stream_id: stream_id}} ->
      # Update track with stream_id and file_path
      track
      |> Ecto.Changeset.change(%{
        stream_id: stream_id,
        file_path: audio_file,
        sample_duration: Keyword.get(parsed_opts, :sample_duration, 60)
      })
      |> Repo.update!()

      Logger.info("✓ Stream URL: #{AudioProcessor.get_stream_url(stream_id)}")

    {:error, reason} ->
      Logger.error("✗ Failed: #{reason}")
  end
end)

Logger.info("\n✓ Batch processing completed!")
