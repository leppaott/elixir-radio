# Implementation Plan - Vinyl Store Streaming Backend v2

## Overview
Transform the backend into a genre-based internet radio platform with admin upload capabilities, hot-reloading, and Docker-first development.

## Phase 1: Database Schema Redesign

### New/Modified Tables

#### 1. Genres (NEW)
```sql
- id (PK)
- name (unique, required)
- description
- image_url
- timestamps
```

#### 2. Albums (MODIFIED)
```sql
- id (PK)
- title (required)
- artist_id (FK -> artists)
- genre_id (FK -> genres)  # NEW
- release_year
- cover_image_url
- description
- timestamps
```

#### 3. Segments (NEW)
```sql
- id (PK)
- track_id (FK -> tracks, unique)
- playlist_data (bytea)     # m3u8 file content
- segment_files (jsonb)     # Array of {segment_number, data_bytea}
- processing_status (enum: pending, processing, completed, failed)
- processing_error (text)
- timestamps
```

#### 4. Tracks (MODIFIED)
```sql
- Remove: stream_id, file_path fields
- Add: upload_status (enum: pending, processing, ready, failed)
```

#### 5. Uploads (NEW - for admin)
```sql
- id (PK)
- track_id (FK -> tracks)
- original_filename
- file_data (bytea)
- mime_type
- file_size
- uploaded_by (future: user_id)
- timestamps
```

### Relationships
- Genre -> Albums (one to many)
- Artist -> Albums (one to many, existing)
- Album -> Tracks (one to many, existing)
- Track -> Segments (one to one)
- Track -> Uploads (one to one)

## Phase 2: API Redesign

### Genre-Based Streaming Endpoints

```
GET /api/genres
Response: [{ id, name, description, image_url, album_count }]

GET /api/genres/:id/albums?page=1&limit=20
Response: { albums: [...], pagination: { page, total_pages, total_count } }

GET /api/albums/:id
Response: { album: {..., artist, tracks } }

GET /api/artists/:id/albums?page=1&limit=20
Response: { artist: {...}, albums: [...], pagination }

GET /api/tracks/:id
Response: { track: {..., album, artist } }
```

### Internet Radio Style Streaming

```
GET /streams/:genre?page=1&limit=10
Response: {
  genre: {...},
  streams: [
    {
      track_id,
      title,
      artist_name,
      album_title,
      playlist_url: "/streams/tracks/:track_id/playlist.m3u8",
      duration,
      sample_duration
    }
  ],
  pagination: {...}
}

GET /streams/tracks/:track_id/playlist.m3u8
Response: HLS playlist (from DB bytea)

GET /streams/tracks/:track_id/segments/:segment_number.ts
Response: MPEG-TS segment (from DB bytea)
```

### Admin Upload API

```
POST /admin/tracks/:track_id/upload
Headers: Content-Type: multipart/form-data
Body: { audio_file: <file> }
Response: {
  upload_id,
  track_id,
  status: "pending",
  message: "Upload received, processing queued"
}

GET /admin/tracks/:track_id/status
Response: {
  track_id,
  upload_status: "processing",
  processing_progress: 45,
  segments_generated: 3
}

POST /admin/tracks
Body: {
  title, album_id, track_number, duration_seconds, sample_duration
}
Response: { track: {...} }
```

## Phase 3: Background Job Processing

### Oban Setup
Use Oban for background job processing:
- Process uploaded audio files
- Generate HLS segments
- Store segments in database
- Update track status

### Worker Flow
```
1. Upload received -> Save to uploads table
2. Enqueue ProcessAudioJob
3. Worker:
   - Fetch upload from DB
   - Create temp file from bytea
   - Run ffmpeg to generate segments
   - Store each segment in segments table as bytea
   - Update track status
   - Clean up temp files
4. Track ready for streaming
```

## Phase 4: Hot-Reloading with Lettuce

### Development Setup
```elixir
# mix.exs
def deps do
  [
    {:lettuce, "~> 0.2.0", only: :dev}
  ]
end

# config/dev.exs
config :lettuce,
  paths: ["lib/"],
  reload_on_save: true
```

### Docker Configuration
```dockerfile
# Dockerfile.dev
FROM elixir:1.18-alpine

RUN apk add --no-cache \
    postgresql-client \
    ffmpeg \
    inotify-tools

WORKDIR /app

# Install hex & rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy source
COPY . .

# Compile
RUN mix compile

CMD ["mix", "run", "--no-halt"]
```

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: elixir_radio_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "4000:4000"
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/elixir_radio_dev
      MIX_ENV: dev
    volumes:
      - ./lib:/app/lib           # Hot-reload source
      - ./config:/app/config     # Hot-reload config
      - ./priv:/app/priv
      - ./public:/app/public
      - build_cache:/app/_build  # Cache build artifacts
      - deps_cache:/app/deps     # Cache dependencies
    depends_on:
      - postgres
    command: mix run --no-halt

volumes:
  postgres_data:
  build_cache:
  deps_cache:
```

## Phase 5: Segment Storage Strategy

### Why Store in DB?
- Simplified deployment (no file system management)
- Atomic operations (track + segments)
- Easy backup/restore
- Consistent state
- Supports distributed systems

### Storage Structure
```elixir
defmodule Segments do
  schema "segments" do
    field :playlist_data, :binary      # ~1-2 KB
    field :segment_files, :map         # JSONB with embedded binary data
    # segment_files: %{
    #   "0" => <<binary_data>>,        # ~100-500 KB each
    #   "1" => <<binary_data>>,
    #   "2" => <<binary_data>>
    # }
    belongs_to :track, Track
  end
end
```

### Size Calculations (per 60s sample)
- 10-second segments = 6 segments
- Each segment: ~300 KB (AAC)
- Total per track: ~1.8 MB
- 1000 tracks: ~1.8 GB
- Acceptable for PostgreSQL with proper indexing

## Phase 6: Seed Data Plan

### Structured Seed Data
```
genres/
├── electronic/
│   ├── album1/
│   │   ├── metadata.json
│   │   ├── track1.flac
│   │   ├── track2.flac
│   │   └── cover.jpg
│   └── album2/
├── jazz/
└── rock/
```

### Seed Script Flow
```elixir
1. Create genres
2. For each genre folder:
   - Read metadata.json
   - Create artist (if not exists)
   - Create album with genre
   - For each audio file:
     - Create track
     - Process with ffmpeg
     - Store segments in DB
3. Log progress
```

## Implementation Order

### Step 1: Database Migration (30 min)
- [ ] Add genres table
- [ ] Add segments table
- [ ] Add uploads table
- [ ] Modify albums (add genre_id)
- [ ] Modify tracks (add upload_status)
- [ ] Create schemas

### Step 2: Hot-Reloading Setup (15 min)
- [ ] Add lettuce dependency
- [ ] Update Dockerfile.dev
- [ ] Update docker-compose.dev.yml
- [ ] Test hot-reload

### Step 3: Background Jobs (45 min)
- [ ] Add Oban dependency
- [ ] Configure Oban
- [ ] Create ProcessAudioJob worker
- [ ] Update AudioProcessor for DB storage
- [ ] Test job processing

### Step 4: API Redesign (60 min)
- [ ] Add genre endpoints
- [ ] Add paginated album endpoints
- [ ] Update streaming endpoints to serve from DB
- [ ] Add admin upload endpoint
- [ ] Update Catalog context
- [ ] Add pagination helpers

### Step 5: Segment Storage (45 min)
- [ ] Create Segments context
- [ ] Modify AudioProcessor to store in DB
- [ ] Create segment serving logic
- [ ] Test streaming from DB

### Step 6: Seed Data (30 min)
- [ ] Create seed data structure
- [ ] Write comprehensive seed script
- [ ] Add sample audio files
- [ ] Test full flow

### Step 7: Frontend Update (30 min)
- [ ] Update demo page for genres
- [ ] Add pagination
- [ ] Add upload form for admin
- [ ] Test end-to-end

## Testing Checklist

- [ ] Docker hot-reload works on file save
- [ ] Upload audio file via API
- [ ] Background job processes file
- [ ] Segments stored in DB correctly
- [ ] Stream plays from DB
- [ ] Pagination works
- [ ] Genre filtering works
- [ ] Admin status endpoint shows progress

## Dependencies to Add

```elixir
# mix.exs
{:oban, "~> 2.17"},           # Background jobs
{:lettuce, "~> 0.2.0", only: :dev},  # Hot-reloading
{:scrivener_ecto, "~> 2.7"}   # Pagination (optional)
```

## Environment Variables

```bash
DATABASE_URL=postgres://postgres:postgres@postgres:5432/elixir_radio_dev
MIX_ENV=dev
PORT=4000
SEGMENT_STORAGE=database  # or "filesystem" for fallback
MAX_UPLOAD_SIZE=52428800  # 50 MB
```

## Rollout Strategy

1. **Phase 1**: Core DB changes + Docker setup (Day 1)
2. **Phase 2**: Background jobs + segment storage (Day 2)
3. **Phase 3**: API redesign + admin endpoints (Day 3)
4. **Phase 4**: Frontend + testing (Day 4)
5. **Phase 5**: Documentation + deployment (Day 5)

## Notes

- Consider adding Redis for Oban in production
- May need to tune PostgreSQL for large binary storage
- Consider CDN for production segment delivery
- Add rate limiting for admin endpoints
- Add authentication before production deployment
- Monitor DB size and consider archival strategy
