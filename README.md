# Elixir Radio - Music Streaming Platform

A full-stack music streaming application with HLS (HTTP Live Streaming) audio playback. Built with Elixir backend and Next.js frontend, featuring genre-based browsing, album collections, and vinyl-style track notation. Inspired by record stores that allow customers to preview tracks before purchasing, this platform can be adapted for both physical and digital storefronts.

## Features

- **HLS Audio Streaming** - Industry-standard adaptive streaming with HTML5 audio player
- **Genre-Based Navigation** - Browse albums by genre with filtering
- **Album & Track Management** - Full metadata with artist info, release years, and cover art
- **Vinyl Track Notation** - Display tracks with side notation (A1, A2, B1, B2)
- **In-Memory Caching** - Cachex for fast segment delivery and reduced database load
- **Background Processing** - Async audio file processing with Oban workers
- **Cursor-Based Pagination** - Efficient browsing through large collections

## Quick Start

```bash
# Start all services (backend + frontend + database)
./start.sh

# Visit http://localhost:3000
```

The start script will:

1. Start PostgreSQL, Elixir backend, and Next.js frontend
2. Create and migrate the database
3. Seed sample data (55 albums with tracks)
4. Open the app in your browser

## Development

### Backend (Elixir)

```bash
# Install dependencies
cd backend
mix deps.get

# Run in Docker (connects to containerized PostgreSQL)
docker compose up app
```

Backend runs on http://localhost:4000

### Frontend (Next.js)

```bash
cd frontend
pnpm install
pnpm dev
```

Frontend runs on http://localhost:3000

### Database

```bash
# Reset database
docker compose exec app mix ecto.reset

# Run migrations
docker compose exec app mix ecto.migrate

# Seed data
docker compose exec app mix run priv/repo/seeds.exs
```

### Upload Tracks

```bash
# Upload audio files to existing tracks
cd backend
./upload_tracks.sh /path/to/audio/files
```

Created with the help of Clause Sonnet 4.5.
