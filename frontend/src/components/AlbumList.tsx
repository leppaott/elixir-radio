"use client";

import { Box, Button, Stack, Typography } from "@mui/material";
import { useState } from "react";
import { AlbumCard } from "@/components/AlbumCard";
import type { Album, AlbumsResponse } from "@/types/api";

interface AlbumListProps {
  initialAlbums: Album[];
  initialPagination: AlbumsResponse["pagination"];
  selectedGenre: number | null;
}

export function AlbumList({
  initialAlbums,
  initialPagination,
  selectedGenre,
}: AlbumListProps) {
  const [albums, setAlbums] = useState(initialAlbums);
  const [hasMore, setHasMore] = useState(initialPagination.has_more);
  const [nextCursor, setNextCursor] = useState(initialPagination.next_cursor);
  const [loading, setLoading] = useState(false);

  const loadMore = async () => {
    if (!hasMore || !nextCursor || loading) return;

    setLoading(true);
    const url = selectedGenre
      ? `/api/albums?genre=${selectedGenre}&per_page=20&after_id=${nextCursor}`
      : `/api/albums?per_page=20&after_id=${nextCursor}`;

    try {
      const res = await fetch(url);
      const data: AlbumsResponse = await res.json();
      setAlbums((prev) => [...prev, ...(data.albums || [])]);
      setHasMore(data.pagination?.has_more || false);
      setNextCursor(data.pagination?.next_cursor || null);
    } finally {
      setLoading(false);
    }
  };

  if (albums.length === 0) {
    return (
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          height: 256,
        }}
      >
        <Typography color="text.secondary">No albums found</Typography>
      </Box>
    );
  }

  return (
    <>
      <Stack spacing={3}>
        {albums.map((album) => (
          <AlbumCard key={album.id} album={album} />
        ))}
      </Stack>

      {/* Pagination */}
      <Box sx={{ mt: 4, display: "flex", justifyContent: "center", gap: 2 }}>
        {hasMore && (
          <Button variant="contained" onClick={loadMore} disabled={loading}>
            {loading ? "Loading..." : "Load More"}
          </Button>
        )}
        {!hasMore && albums.length > 0 && (
          <Typography color="text.secondary" sx={{ py: 1.5 }}>
            End of results
          </Typography>
        )}
      </Box>
    </>
  );
}
