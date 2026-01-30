# Seed script that can run against a running application
# Usage: docker compose exec -T app elixir --eval-string "File.read!(\"priv/repo/seed_remote.exs\") |> Code.eval_string()"

alias ElixirRadio.Repo
alias ElixirRadio.Catalog

IO.puts("🌱 Seeding database...")

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

IO.puts("✓ Created genres")

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

IO.puts("✓ Created artists")

# Create albums
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
    description: "Live jazz recordings"
  })

{:ok, album4} =
  Catalog.create_album(%{
    title: "Highway Freedom",
    artist_id: artist3.id,
    genre_id: rock.id,
    release_year: 2020,
    cover_image_url: "https://example.com/albums/highway.jpg",
    description: "Classic rock anthems"
  })

IO.puts("✓ Created albums")

# Create tracks
tracks = [
  {"Music is the Danger (Club edit)", album1.id, 1, 248},
  {"Midnight Drive", album1.id, 2, 312},
  {"Pulse", album1.id, 3, 275},
  {"City Lights", album2.id, 1, 294},
  {"Neon Dreams", album2.id, 2, 268},
  {"After Hours", album2.id, 3, 301},
  {"Blue Note", album3.id, 1, 342},
  {"Swing Time", album3.id, 2, 286},
  {"Born to Run Free", album4.id, 1, 267},
  {"Thunder Road", album4.id, 2, 298}
]

for {title, album_id, track_number, duration} <- tracks do
  {:ok, _track} =
    Catalog.create_track(%{
      title: title,
      album_id: album_id,
      track_number: track_number,
      duration_seconds: duration,
      upload_status: "pending"
    })
end

IO.puts("✓ Created #{length(tracks)} tracks")
IO.puts("✅ Seeding complete!")
