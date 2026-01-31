"use client";

import { ChevronLeft, ChevronRight } from "@mui/icons-material";
import { Box, Button, Stack, Typography } from "@mui/material";
import { useEffect, useState } from "react";
import { AlbumCard } from "@/components/AlbumCard";
import { getAlbumsUrl } from "@/lib/api";
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
  const [currentCursor, setCurrentCursor] = useState<number | null>(null);
  const [prevCursors, setPrevCursors] = useState<(number | null)[]>([]);
  const [loading, setLoading] = useState(false);

  // Reset state when genre changes (new initial data from server)
  useEffect(() => {
    setAlbums(initialAlbums);
    setHasMore(initialPagination.has_more);
    setNextCursor(initialPagination.next_cursor);
    setCurrentCursor(null);
    setPrevCursors([]);
  }, [initialAlbums, initialPagination]);

  const loadNext = async () => {
    if (!hasMore || !nextCursor || loading) return;

    setLoading(true);
    // Clear albums to force re-render
    setAlbums([]);

    const url = getAlbumsUrl({
      genre: selectedGenre,
      per_page: 20,
      after_id: nextCursor,
    });

    try {
      const res = await fetch(url);
      const data: AlbumsResponse = await res.json();

      setPrevCursors((prev) => [...prev, currentCursor]);
      setCurrentCursor(nextCursor);
      setHasMore(data.pagination?.has_more ?? false);
      setNextCursor(data.pagination?.next_cursor ?? null);
      setAlbums(data.albums || []);

      // Scroll after state update
      setTimeout(() => window.scrollTo({ top: 0, behavior: "auto" }), 0);
    } finally {
      setLoading(false);
    }
  };

  const loadPrev = async () => {
    if (prevCursors.length === 0 || loading) return;

    const newPrevCursors = [...prevCursors];
    const prevPageCursor = newPrevCursors.pop();

    setLoading(true);
    // Clear albums to force re-render
    setAlbums([]);

    const url = getAlbumsUrl({
      genre: selectedGenre,
      per_page: 20,
      after_id: prevPageCursor ?? undefined,
    });

    try {
      const res = await fetch(url);
      const data: AlbumsResponse = await res.json();

      setPrevCursors(newPrevCursors);
      setCurrentCursor(prevPageCursor ?? null);
      setHasMore(data.pagination?.has_more ?? false);
      setNextCursor(data.pagination?.next_cursor ?? null);
      setAlbums(data.albums || []);

      setTimeout(() => window.scrollTo({ top: 0, behavior: "auto" }), 0);
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
      <Box
        sx={{
          mt: 4,
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          gap: 2,
        }}
      >
        <Button
          variant="outlined"
          startIcon={<ChevronLeft />}
          onClick={loadPrev}
          disabled={loading || prevCursors.length === 0}
        >
          Previous
        </Button>
        <Typography variant="body2" color="text.secondary">
          Page {prevCursors.length + 1}
        </Typography>
        <Button
          variant="outlined"
          endIcon={<ChevronRight />}
          onClick={loadNext}
          disabled={loading || !hasMore}
        >
          Next
        </Button>
      </Box>
    </>
  );
}
