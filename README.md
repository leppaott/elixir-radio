# Elixir Radio - Genre-Based Record Store Streaming Backend

A high-performance audio streaming backend built with Elixir that serves HLS (HTTP Live Streaming) audio samples organized by genre. Perfect for record stores allowing customers to preview tracks before purchasing.

## Features

- 🎵 **HLS Audio Streaming** - Industry-standard adaptive streaming
- 🎸 **Genre-Based Navigation** - Browse by genre (Electronic, Jazz, Rock, etc.)
- 💾 **Database Segment Storage** - All segments stored in PostgreSQL
- 📤 **Admin Upload API** - Upload audio files with automatic processing
- ⚙️ **Background Job Processing** - Oban workers for async audio processing
- 🔄 **Hot-Reloading** - Lettuce integration for instant code updates in Docker
- 🐳 **Docker-First** - Complete development environment in Docker
- 🎛️ **Configurable Samples** - 2-4 minute samples (configurable per track)
- 🚀 **REST API** - Full-featured paginated API

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

- `GET /api/genres?page=1&per_page=20` - List genres (paginated)
- `GET /api/genres/:id/albums?page=1&per_page=20` - Albums by genre (paginated)

### Albums & Artists

- `GET /api/albums?page=1&per_page=20` - List albums (paginated)
- `GET /api/albums/:id` - Get album with tracks
- `GET /api/artists/:id/albums?page=1&per_page=20` - Albums by artist (paginated)

### Tracks

- `GET /api/tracks/:id` - Get track details

### Streaming (Internet Radio Style)

- `GET /streams/:genre?page=1&per_page=50` - Get streamable tracks by genre
- `GET /streams/tracks/:track_id/playlist.m3u8` - HLS playlist
- `GET /streams/tracks/:track_id/segments/:number.ts` - HLS segment

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
- All segments stored in PostgreSQL as `bytea`
- ~3.6 MB per track (120s sample with 10s segments)
- Atomic operations, simplified deployment

### Processing Flow
1. Upload → stored in `uploads` table
2. Oban job queued → `ProcessAudioJob`
3. Worker processes with FFmpeg
4. Segments stored in `segments` table
5. Track status → "ready"

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

Built with ❤️ using **Elixir** · **Oban** · **Lettuce** · **HLS**
