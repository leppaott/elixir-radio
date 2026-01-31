"use client";

import { useEffect, useState } from "react";
import type { Genre } from "@/types/api";

interface GenreBarProps {
  selectedGenre: number | null;
  onSelectGenre: (genreId: number | null) => void;
}

export function GenreBar({ selectedGenre, onSelectGenre }: GenreBarProps) {
  const [genres, setGenres] = useState<Genre[]>([]);

  useEffect(() => {
    fetch("/api/genres?per_page=50")
      .then((res) => res.json())
      .then((data) => setGenres(data.genres || []));
  }, []);

  return (
    <div className="bg-gray-900 px-6 py-3">
      <div className="flex items-center gap-3 overflow-x-auto">
        <button
          type="button"
          onClick={() => onSelectGenre(null)}
          className={`px-3 py-1.5 rounded-full whitespace-nowrap transition text-sm ${
            selectedGenre === null
              ? "bg-blue-600 text-white"
              : "bg-gray-800 text-gray-300 hover:bg-gray-700"
          }`}
        >
          All Genres
        </button>
        {genres.map((genre) => (
          <button
            key={genre.id}
            type="button"
            onClick={() => onSelectGenre(genre.id)}
            className={`px-3 py-1.5 rounded-full whitespace-nowrap transition text-sm ${
              selectedGenre === genre.id
                ? "bg-blue-600 text-white"
                : "bg-gray-800 text-gray-300 hover:bg-gray-700"
            }`}
          >
            {genre.name}
          </button>
        ))}
      </div>
    </div>
  );
}
