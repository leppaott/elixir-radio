# Development Setup

## Running Locally

### Backend (Docker)
```bash
docker compose up
docker compose exec app mix ecto.create
docker compose exec app mix ecto.migrate
docker compose exec app mix run priv/repo/seeds.exs
```

Backend runs at: http://localhost:4000 (API only)

### Frontend (Local)
```bash
cd frontend
pnpm install
pnpm dev
```

Frontend runs at: http://localhost:3000
API calls automatically proxy to backend at :4000

## Production Deployment

Backend and frontend run as separate services:
- Backend: API and streaming endpoints at :4000
- Frontend: Next.js server at :3000

Use a reverse proxy (nginx/traefik) to route:
- `/api/*` → backend
- `/streams/*` → backend
- `/admin/*` → backend
- `/*` → frontend
