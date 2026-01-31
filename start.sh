#!/bin/bash

# Quick start script for Elixir Radio

set -e

echo "🎵 Elixir Radio - Quick Start"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker is not running. Please start Docker and try again."
  exit 1
fi

echo "✓ Docker is running"
echo ""

# Build and start services
echo "📦 Building and starting services..."
docker compose up -d postgres

echo "⏳ Waiting for PostgreSQL to be ready..."
until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
  sleep 1
done
echo "✓ PostgreSQL is ready"

# Setup database (without starting app)
echo "🗄️  Setting up database..."
docker compose run --rm app mix deps.get
docker compose run --rm app mix ecto.create || echo "✓ Database already exists"
docker compose run --rm app mix ecto.migrate

# Seed data (only if DB is empty)
echo "🌱 Checking if database needs seeding..."
GENRE_COUNT=$(docker compose exec -T postgres psql -U postgres -d elixir_radio -t -c "SELECT COUNT(*) FROM genres;" 2>/dev/null | xargs || echo "0")

if [ "$GENRE_COUNT" -eq "0" ]; then
  echo "📝 Seeding sample data..."
  docker compose run --rm -e MIX_ENV=dev app mix run priv/repo/seeds.exs
else
  echo "✓ Database already has data (skipping seed)"
fi

# Now start the app
echo "🚀 Starting application..."
docker compose up -d app

echo ""
echo "================================"
echo "✓ Setup complete!"
echo ""
echo "🚀 Server running at: http://localhost:4000"
echo "📚 API Documentation: http://localhost:4000"
echo ""
echo "Sample API calls:"
echo "  # List all genres"
echo "  curl http://localhost:4000/api/genres"
echo ""
echo "  # Get an album with tracks"
echo "  curl http://localhost:4000/api/albums/1"
echo ""
echo "  # Stream Electronic tracks"
echo "  curl http://localhost:4000/streams/Electronic"
echo ""
echo "  # Get track details"
echo "  curl http://localhost:4000/api/tracks/1"
echo ""
echo "Useful commands:"
echo "  # View logs:"
echo "  docker compose logs -f app"
echo ""
echo "  # Run tests:"
echo "  docker compose exec app mix test"
echo ""
echo "  # Access database:"
echo "  docker compose exec postgres psql -U postgres -d elixir_radio"
echo ""
echo "  # Restart app:"
echo "  docker compose restart app"
echo ""
echo "  # Stop all services:"
echo "  docker compose down"
echo ""
