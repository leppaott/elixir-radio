"use client";

import { useEffect, useState } from "react";
import { AlbumCard } from "@/components/AlbumCard";
import { AudioPlayer } from "@/components/AudioPlayer";
import { GenreBar } from "@/components/GenreBar";
import type { Album, AlbumsResponse } from "@/types/api";

export default function HomePage() {
  const [selectedGenre, setSelectedGenre] = useState<number | null>(null);
  const [albums, setAlbums] = useState<Album[]>([]);
  const [loading, setLoading] = useState(true);
  const [hasMore, setHasMore] = useState(false);
  const [nextCursor, setNextCursor] = useState<number | null>(null);

  useEffect(() => {
    setLoading(true);
    const url = selectedGenre
      ? `/api/albums?genre=${selectedGenre}&per_page=20`
      : "/api/albums?per_page=20";

    fetch(url)
      .then((res) => res.json())
      .then((data: AlbumsResponse) => {
        setAlbums(data.albums || []);
        setHasMore(data.pagination?.has_more || false);
        setNextCursor(data.pagination?.next_cursor || null);
      })
      .finally(() => setLoading(false));
  }, [selectedGenre]);

  const loadMore = () => {
    if (!hasMore || !nextCursor) return;

    const url = selectedGenre
      ? `/api/albums?genre=${selectedGenre}&per_page=20&after_id=${nextCursor}`
      : `/api/albums?per_page=20&after_id=${nextCursor}`;

    fetch(url)
      .then((res) => res.json())
      .then((data: AlbumsResponse) => {
        setAlbums((prev) => [...prev, ...(data.albums || [])]);
        setHasMore(data.pagination?.has_more || false);
        setNextCursor(data.pagination?.next_cursor || null);
      });
  };

  return (
    <div className="h-screen flex flex-col">
      {/* Top Bar with Genre Bar and Player */}
      <div className="flex items-center border-b border-gray-800">
        {/* Genre Bar - Left Side */}
        <div className="flex-1">
          <GenreBar
            selectedGenre={selectedGenre}
            onSelectGenre={setSelectedGenre}
          />
        </div>

        {/* Compact Player - Right Side */}
        <div className="w-96 border-l border-gray-800">
          <AudioPlayer />
        </div>
      </div>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto p-6">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-400">Loading albums...</p>
          </div>
        ) : albums.length === 0 ? (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-400">No albums found</p>
          </div>
        ) : (
          <>
            <div className="space-y-6">
              {albums.map((album) => (
                <AlbumCard key={album.id} album={album} />
              ))}
            </div>

            {hasMore && (
              <div className="mt-8 flex justify-center">
                <button
                  type="button"
                  onClick={loadMore}
                  className="px-6 py-3 bg-blue-600 hover:bg-blue-700 rounded-lg transition"
                >
                  Load More
                </button>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
