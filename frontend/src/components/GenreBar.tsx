"use client";

import { Box, Chip, Stack } from "@mui/material";
import Link from "next/link";
import type { Genre } from "@/types/api";

interface GenreBarProps {
  genres: Genre[];
  selectedGenre: number | null;
}

export function GenreBar({ genres, selectedGenre }: GenreBarProps) {
  return (
    <Box sx={{ bgcolor: "background.paper", px: 3, py: 2 }}>
      <Stack direction="row" spacing={1} sx={{ overflowX: "auto" }}>
        <Chip
          label="All Genres"
          component={Link}
          href="/"
          clickable
          color={selectedGenre === null ? "primary" : "default"}
          variant={selectedGenre === null ? "filled" : "outlined"}
        />
        {genres.map((genre) => (
          <Chip
            key={genre.id}
            label={genre.name}
            component={Link}
            href={`/?genre=${genre.id}`}
            clickable
            color={selectedGenre === genre.id ? "primary" : "default"}
            variant={selectedGenre === genre.id ? "filled" : "outlined"}
          />
        ))}
      </Stack>
    </Box>
  );
}
