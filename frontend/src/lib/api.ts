const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

interface AlbumsParams {
  genre?: number | null;
  after_id?: number | null;
  per_page?: number;
  sort_by?: string;
  sort_order?: "asc" | "desc";
}

function buildQueryString(
  params: Record<string, string | number | undefined | null>,
): string {
  const searchParams = new URLSearchParams();

  Object.entries(params).forEach(([key, value]) => {
    if (value !== null && value !== undefined) {
      searchParams.append(key, String(value));
    }
  });

  const query = searchParams.toString();
  return query ? `?${query}` : "";
}

export function getAlbumsUrl(params: AlbumsParams = {}): string {
  const { genre, after_id, per_page = 20, sort_by, sort_order } = params;

  return `${API_BASE}/api/albums${buildQueryString({
    genre,
    after_id,
    per_page,
    sort_by,
    sort_order,
  })}`;
}

export function getTracksUrl(trackId: number): string {
  return `${API_BASE}/api/tracks/${trackId}`;
}

export function getGenresUrl(per_page = 50): string {
  return `${API_BASE}/api/genres${buildQueryString({ per_page })}`;
}
