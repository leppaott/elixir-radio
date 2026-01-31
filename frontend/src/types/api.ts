export interface Genre {
  id: number;
  name: string;
  description: string | null;
  image_url: string | null;
  album_count?: number;
}

export interface Artist {
  id: number;
  name: string;
  bio: string | null;
  image_url: string | null;
}

export interface Album {
  id: number;
  title: string;
  artist_id: number;
  genre_id: number;
  release_year: number | null;
  cover_image_url: string | null;
  description: string | null;
  artist?: Artist;
  genre?: Genre;
  tracks?: Track[];
}

export interface Track {
  id: number;
  title: string;
  album_id: number;
  track_number: number;
  duration_seconds: number | null;
  sample_duration: number;
  upload_status: "pending" | "processing" | "ready" | "failed";
  stream_url?: string;
  album?: Album;
  artist?: Artist;
}

export interface PaginatedResponse<T> {
  data: T[];
  has_more: boolean;
  next_cursor: number | null;
}

export interface AlbumsResponse {
  albums: Album[];
  pagination: {
    per_page: number;
    has_more: boolean;
    next_cursor: number | null;
    sort_by: string;
    sort_order: string;
  };
}
