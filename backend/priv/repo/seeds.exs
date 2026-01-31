#!/usr/bin/env elixir

# Run this script with: mix run priv/repo/seeds.exs

alias ElixirRadio.Catalog

require Logger

# Start the application
Application.ensure_all_started(:elixir_radio)

Logger.info("Seeding database...")

# Create genres
{:ok, electronic} =
  Catalog.create_genre(%{
    name: "Electronic",
    description: "Electronic music including house, techno, ambient, and more",
    image_url: "https://example.com/genres/electronic.jpg"
  })

{:ok, jazz} =
  Catalog.create_genre(%{
    name: "Jazz",
    description: "Jazz music from traditional to modern fusion",
    image_url: "https://example.com/genres/jazz.jpg"
  })

{:ok, rock} =
  Catalog.create_genre(%{
    name: "Rock",
    description: "Rock music spanning decades",
    image_url: "https://example.com/genres/rock.jpg"
  })

Logger.info("Created genres: Electronic, Jazz, Rock")

# Create artists
{:ok, artist1} =
  Catalog.create_artist(%{
    name: "Axel Le Baron",
    bio: "French electronic music producer",
    image_url: "https://example.com/artists/axel.jpg"
  })

{:ok, artist2} =
  Catalog.create_artist(%{
    name: "The Jazz Collective",
    bio: "Modern jazz ensemble from New York",
    image_url: "https://example.com/artists/jazz_collective.jpg"
  })

{:ok, artist3} =
  Catalog.create_artist(%{
    name: "Midnight Riders",
    bio: "Classic rock band",
    image_url: "https://example.com/artists/midnight_riders.jpg"
  })

Logger.info("Created artists")

# Create albums with genres
{:ok, album1} =
  Catalog.create_album(%{
    title: "Electronic Dreams",
    artist_id: artist1.id,
    genre_id: electronic.id,
    release_year: 2024,
    cover_image_url: "https://example.com/albums/dreams.jpg",
    description: "A journey through electronic soundscapes"
  })

{:ok, album2} =
  Catalog.create_album(%{
    title: "Neon Nights",
    artist_id: artist1.id,
    genre_id: electronic.id,
    release_year: 2023,
    cover_image_url: "https://example.com/albums/neon.jpg",
    description: "Late night electronic vibes"
  })

{:ok, album3} =
  Catalog.create_album(%{
    title: "Midnight Sessions",
    artist_id: artist2.id,
    genre_id: jazz.id,
    release_year: 2023,
    cover_image_url: "https://example.com/albums/midnight.jpg",
    description: "Live jazz recordings from late night sessions"
  })

{:ok, album4} =
  Catalog.create_album(%{
    title: "Highway Freedom",
    artist_id: artist3.id,
    genre_id: rock.id,
    release_year: 2020,
    cover_image_url: "https://example.com/albums/highway.jpg",
    description: "Classic rock anthems for the road"
  })

Logger.info("Created albums")

# Create tracks
tracks_data = [
  # Electronic Dreams
  %{
    title: "Music is the Danger (Club edit)",
    album_id: album1.id,
    track_number: 1,
    duration_seconds: 320,
    sample_duration: 120
  },
  %{
    title: "Neon Lights",
    album_id: album1.id,
    track_number: 2,
    duration_seconds: 280,
    sample_duration: 120
  },
  %{
    title: "Digital Sunrise",
    album_id: album1.id,
    track_number: 3,
    duration_seconds: 240,
    sample_duration: 120
  },

  # Neon Nights
  %{
    title: "City After Dark",
    album_id: album2.id,
    track_number: 1,
    duration_seconds: 300,
    sample_duration: 120
  },
  %{
    title: "Purple Haze Dreams",
    album_id: album2.id,
    track_number: 2,
    duration_seconds: 340,
    sample_duration: 120
  },

  # Midnight Sessions
  %{
    title: "Blue Note",
    album_id: album3.id,
    track_number: 1,
    duration_seconds: 420,
    sample_duration: 150
  },
  %{
    title: "Moonlight Serenade",
    album_id: album3.id,
    track_number: 2,
    duration_seconds: 380,
    sample_duration: 150
  },
  %{
    title: "Smokey Room",
    album_id: album3.id,
    track_number: 3,
    duration_seconds: 360,
    sample_duration: 150
  },

  # Highway Freedom
  %{
    title: "Born to Ride",
    album_id: album4.id,
    track_number: 1,
    duration_seconds: 260,
    sample_duration: 90
  },
  %{
    title: "Thunder Road",
    album_id: album4.id,
    track_number: 2,
    duration_seconds: 300,
    sample_duration: 90
  }
]

Enum.each(tracks_data, fn track_data ->
  {:ok, track} = Catalog.create_track(track_data)
  Logger.info("Created track: #{track.title}")
end)

Logger.info("\n✓ Seeding completed!")
Logger.info("\nNext steps:")
Logger.info("1. Use the admin API to upload audio files:")
Logger.info("   POST /admin/tracks/:id/upload with audio_file")
Logger.info("2. Or use Docker Compose to start the full stack:")
Logger.info("   docker compose up")
Logger.info("3. Visit http://localhost:4000 to see API documentation")
