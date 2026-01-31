#!/bin/bash

# Upload tracks from ~/Songs directory to backend
# Randomly skips ~10% of tracks to simulate incomplete albums

SONGS_DIR="${1:-$HOME/Songs}"
API_URL="${API_URL:-http://localhost:4000}"
SKIP_PROBABILITY=10        # 10% chance to skip
MAX_PARALLEL="${MAX_PARALLEL:-10}"  # Number of parallel uploads

echo "Starting track upload from $SONGS_DIR"
echo "-------------------------------------------"

if [ ! -d "$SONGS_DIR" ]; then
  echo "Directory $SONGS_DIR not found songs upload skipped."
  exit 0
fi

# Get total number of tracks from database
echo "Fetching track count from database..."
max_track_id=$(docker compose exec -T postgres psql -U postgres -d elixir_radio -t -c "SELECT MAX(id) FROM tracks" | tr -d ' ')

if [ -z "$max_track_id" ]; then
  echo "ERROR: Could not determine track count from database"
  exit 1
fi

echo "Found $max_track_id tracks in database"

# Count total files
total_files=$(find "$SONGS_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.wav" -o -name "*.m4a" \) | wc -l | tr -d ' ')
echo "Found $total_files audio files"
echo ""

# Get all audio files into an array
audio_files=()
while IFS= read -r file; do
  audio_files+=("$file")
done < <(find "$SONGS_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.wav" -o -name "*.m4a" \))

if [ ${#audio_files[@]} -eq 0 ]; then
  echo "No audio files found in $SONGS_DIR"
  exit 0
fi

# Loop through tracks, cycling through audio files
file_index=0
active_jobs=0

upload_track() {
  local track_id=$1
  local file=$2
  local filename=$(basename "$file")

  echo "Uploading track ID $track_id: $filename"

  http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL/admin/tracks/$track_id/upload" \
    -F "audio_file=@$file")

  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ] || [ "$http_code" = "202" ]; then
    echo "   Track ID $track_id: Success (HTTP $http_code)"
  else
    echo "   Track ID $track_id: Failed (HTTP $http_code)"
  fi
}

for track_id in $(seq 1 $max_track_id); do
  # Random skip (10% chance)
  random_num=$((RANDOM % 100))
  if [ $random_num -lt $SKIP_PROBABILITY ]; then
    echo "Skipping track ID $track_id (random skip)"
    continue
  fi

  # Get current file (cycle through array)
  file="${audio_files[$file_index]}"
  file_index=$(( (file_index + 1) % ${#audio_files[@]} ))

  # Start upload in background
  upload_track $track_id "$file" &

  active_jobs=$((active_jobs + 1))

  # Wait for some jobs to finish if we hit the parallel limit
  if [ $active_jobs -ge $MAX_PARALLEL ]; then
    wait -n 2>/dev/null || true
    active_jobs=$((active_jobs - 1))
  fi
done

# Wait for all remaining background jobs
echo ""
echo "Waiting for remaining uploads to complete..."
wait

echo ""
echo "-------------------------------------------"
echo "Upload process completed"
