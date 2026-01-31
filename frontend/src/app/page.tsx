import { Box, Container, Divider } from "@mui/material";
import { AlbumList } from "@/components/AlbumList";
import { AudioPlayer } from "@/components/AudioPlayer";
import { GenreBar } from "@/components/GenreBar";
import type { AlbumsResponse, Genre } from "@/types/api";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

async function getGenres(): Promise<Genre[]> {
  const res = await fetch(`${API_BASE}/api/genres?per_page=50`, {
    cache: "force-cache",
  });
  if (!res.ok) return [];
  const data = await res.json();
  return data.genres || [];
}

async function getAlbums(genreId?: string): Promise<AlbumsResponse> {
  const url = genreId
    ? `${API_BASE}/api/albums?genre=${genreId}&per_page=20`
    : `${API_BASE}/api/albums?per_page=20`;

  const res = await fetch(url, { cache: "no-store" });
  if (!res.ok)
    return {
      albums: [],
      pagination: {
        per_page: 20,
        has_more: false,
        next_cursor: null,
        sort_by: "id",
        sort_order: "desc",
      },
    };
  return res.json();
}

export default async function HomePage({
  searchParams,
}: {
  searchParams: { genre?: string };
}) {
  const genres = await getGenres();
  const albumsData = await getAlbums(searchParams.genre);
  const selectedGenre = searchParams.genre ? Number(searchParams.genre) : null;

  return (
    <Box sx={{ height: "100vh", display: "flex", flexDirection: "column" }}>
      <GenreBar genres={genres} selectedGenre={selectedGenre} />
      <Divider />

      <Box sx={{ display: "flex", flex: 1, overflow: "hidden" }}>
        <Box sx={{ width: 320, borderRight: 1, borderColor: "divider" }}>
          <AudioPlayer />
        </Box>

        <Box sx={{ flex: 1, overflow: "auto" }}>
          <Container maxWidth="lg" sx={{ py: 3 }}>
            <AlbumList
              initialAlbums={albumsData.albums}
              initialPagination={albumsData.pagination}
              selectedGenre={selectedGenre}
            />
          </Container>
        </Box>
      </Box>
    </Box>
  );
}
