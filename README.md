# Elixir Radio - Genre-Based Record Store Streaming Backend

A high-performance audio streaming backend built with Elixir that serves HLS (HTTP Live Streaming) audio samples organized by genre. Perfect for record stores allowing customers to preview tracks before purchasing.

## Features

- **HLS Audio Streaming** - Industry-standard adaptive streaming
- **Genre-Based Navigation** - Browse by genre (Electronic, Jazz, Rock, etc.)
- **Database Segment Storage** - All segments stored in PostgreSQL
- **Admin Upload API** - Upload audio files with automatic processing
- **Background Job Processing** - Oban workers for async audio processing
- **Hot-Reloading** - Lettuce integration for instant code updates in Docker
- **Docker-First** - Complete development environment in Docker
- **Configurable Samples** - 2-4 minute samples (configurable per track)
- **REST API** - Full-featured paginated API

## Quick Start with Docker

```bash
# Clone and enter directory
cd elixir-radio

# Start services
docker compose up

# In another terminal, setup database
docker compose exec app mix ecto.create
docker compose exec app mix ecto.migrate
docker compose exec app mix run priv/repo/seeds.exs

# Visit http://localhost:4000
```

## API Endpoints

### Genres

- `GET /api/genres?per_page=20&after_id=5&sort_by=name&sort_order=asc` - List genres (cursor pagination)

### Albums & Artists

- `GET /api/albums?per_page=20&after_id=15&sort_by=id&sort_order=desc` - List albums (cursor pagination)
- `GET /api/albums?genre=1&per_page=20&after_id=10&sort_by=id&sort_order=desc` - Albums by genre (cursor pagination)
- `GET /api/albums?artist=3&per_page=20&after_id=8&sort_by=id&sort_order=desc` - Albums by artist (cursor pagination)
- `GET /api/albums/:id` - Get album with tracks

### Tracks

- `GET /api/tracks/:id` - Get track details

### Streaming (Internet Radio Style)

- `GET /streams/:genre?per_page=50&after_id=100&sort_by=id&sort_order=asc` - Get streamable tracks by genre (cursor pagination)
- `GET /streams/tracks/:track_id/playlist.m3u8` - HLS playlist
- `GET /streams/tracks/:track_id/segments/:number.ts` - HLS segment

**Cursor Pagination:** Use `after_id` (ID from `next_cursor` in response) to get the next page. All paginated endpoints support `sort_by` (column name) and `sort_order` (`asc`/`desc`). Response includes `has_more` and `next_cursor`.

### Admin

- `POST /admin/albums` - Create album with tracks (metadata only)
- `GET /admin/albums/:id/status` - Check album upload progress
- `POST /admin/tracks` - Create track
- `POST /admin/tracks/:id/upload` - Upload audio file
- `GET /admin/tracks/:id/status` - Check processing status

## Workflow Example

### Upload and Process an Album

```bash
# 1. Create album with tracks (metadata only - one call)
curl -X POST http://localhost:4000/admin/albums \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Album",
    "artist_id": 1,
    "genre_id": 1,
    "release_year": 2024,
    "tracks": [
      {"title": "Song 1", "track_number": 1, "sample_duration": 120},
      {"title": "Song 2", "track_number": 2, "sample_duration": 90}
    ]
  }'

# Response: {"album_id": 5, "tracks": [{"id": 12, "upload_url": "/admin/tracks/12/upload"}, ...]}

# 2. Upload audio files (can be done in parallel)
curl -X POST http://localhost:4000/admin/tracks/12/upload \
  -F "audio_file=@song1.flac"

curl -X POST http://localhost:4000/admin/tracks/13/upload \
  -F "audio_file=@song2.mp3"

# 3. Check album status (shows progress for all tracks)
curl http://localhost:4000/admin/albums/5/status

# Response shows: ready_count, processing_count, pending_count, complete: true/false

# 4. Stream when ready
curl http://localhost:4000/streams/tracks/12/playlist.m3u8
```

### Upload Individual Track (Alternative)

```bash
# For adding tracks to existing album
curl -X POST http://localhost:4000/admin/tracks \
  -H "Content-Type: application/json" \
  -d '{"title":"Bonus Track","album_id":1,"track_number":10,"sample_duration":120}'

curl -X POST http://localhost:4000/admin/tracks/14/upload \
  -F "audio_file=@bonus.flac"
```

## Architecture

### Storage
- Individual segment files stored in PostgreSQL `segment_files` table as raw `bytea` (no Base64)
- ~200KB per segment file, ~12 segments per 120s track
- Cursor-based pagination for efficient querying at scale
- Query only the specific segment needed (not entire track data)

### Processing Flow
1. Upload → stored in `uploads` table
2. Oban job queued → `ProcessAudioJob`
3. Worker processes with FFmpeg
4. Each segment file stored as separate row in `segment_files` table
5. Track status → "ready"

### Pagination
- **Cursor-based:** Use `after_id` + `sort_by` + `sort_order` for efficient pagination
- No offset queries that slow down at high page numbers
- Response includes `has_more` boolean and `next_cursor` for next page
- Supports sorting by any column (id, name, inserted_at, etc.)

## Development

### Hot-Reload
Edit files in `lib/` or `config/` - changes reload automatically!

### Database Commands
```bash
docker compose exec app mix ecto.reset
docker compose exec app mix ecto.migrate
docker compose exec app mix run priv/repo/seeds.exs
```

### View Logs
```bash
docker compose logs -f app
```

### Configuration

Sample duration (per track): 60-240 seconds (default: 120s)
Upload limit: 50 MB
Pagination: 20-50 items per page (configurable). Use `page` and `per_page` query parameters on list endpoints, for example `?page=1&per_page=20`.

## Project Structure

```
lib/elixir_radio/
├── catalog/          # Schemas (Genre, Artist, Album, Track, Upload, Segment)
├── workers/          # Oban background jobs
├── application.ex    # App supervisor
├── catalog.ex        # Business logic
└── streaming_server.ex  # HTTP API

priv/repo/
├── migrations/       # Database schema
└── seeds.exs         # Sample data

config/
├── config.exs        # Oban config
└── dev.exs           # Lettuce hot-reload

docker-compose.yml    # Services (app + postgres)
Dockerfile.dev        # Dev container with FFmpeg
```

## See Also

- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Detailed implementation guide
- API documentation at http://localhost:4000 when running

---

Built with **Elixir** · **Oban** · **Lettuce** · **HLS**
