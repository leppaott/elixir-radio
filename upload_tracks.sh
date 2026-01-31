#!/bin/bash

# Upload tracks from ~/Songs directory to backend
# Randomly skips ~10% of tracks to simulate incomplete albums

SONGS_DIR="$HOME/Songs"
API_URL="${API_URL:-http://localhost:4000}"
TRACK_ID=1
SKIP_PROBABILITY=10  # 10% chance to skip

echo "Starting track upload from $SONGS_DIR"
echo "-------------------------------------------"

if [ ! -d "$SONGS_DIR" ]; then
  echo "ERROR: Directory $SONGS_DIR not found"
  exit 1
fi

# Count total files
TOTAL_FILES=$(find "$SONGS_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.wav" -o -name "*.m4a" \) | wc -l | tr -d ' ')
echo "Found $TOTAL_FILES audio files"
echo ""

# Loop through audio files
find "$SONGS_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.wav" -o -name "*.m4a" \) | while IFS= read -r file; do
  # Random skip (10% chance)
  RANDOM_NUM=$((RANDOM % 100))
  if [ $RANDOM_NUM -lt $SKIP_PROBABILITY ]; then
    echo "Skipping track ID $TRACK_ID (random skip)"
    TRACK_ID=$((TRACK_ID + 1))
    continue
  fi

  FILENAME=$(basename "$file")
  echo "Uploading track ID $TRACK_ID: $FILENAME"

  # Upload with curl
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/admin/tracks/$TRACK_ID/upload" \
    -F "audio_file=@$file" 2>&1)

  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  BODY=$(echo "$RESPONSE" | head -n-1)

  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "   Success (HTTP $HTTP_CODE)"
  elif [ "$HTTP_CODE" = "404" ]; then
    echo "   Track ID $TRACK_ID not found (HTTP 404) - stopping uploads"
    break
  else
    echo "   Failed (HTTP $HTTP_CODE)"
  TRACK_ID=$((TRACK_ID + 1))

  # Small delay to avoid overwhelming the server
  sleep 0.5
done

echo "-------------------------------------------"
echo "Upload process completed"
