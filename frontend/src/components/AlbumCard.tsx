"use client";

import { IconPlayerPlay } from "@tabler/icons-react";
import Image from "next/image";
import { usePlayer } from "@/contexts/PlayerContext";
import type { Album } from "@/types/api";

interface AlbumCardProps {
  album: Album;
}

export function AlbumCard({ album }: AlbumCardProps) {
  const { play, currentTrack } = usePlayer();

  return (
    <div className="bg-gray-900 rounded-lg p-4 border border-gray-800">
      <div className="grid grid-cols-[auto_1fr_2fr] gap-4">
        {/* Album Cover */}
        <div className="w-24 h-24 relative">
          {album.cover_image_url ? (
            <Image
              src={album.cover_image_url}
              alt={album.title}
              fill
              className="object-cover rounded"
            />
          ) : (
            <div className="w-full h-full bg-gray-800 rounded flex items-center justify-center">
              <span className="text-gray-600 text-2xl">♪</span>
            </div>
          )}
        </div>

        {/* Album Metadata */}
        <div className="flex flex-col justify-center">
          <h3 className="text-lg font-bold text-white">{album.title}</h3>
          <p className="text-sm text-gray-400">{album.artist?.name}</p>
          {album.release_year && (
            <p className="text-xs text-gray-500">{album.release_year}</p>
          )}
          {album.genre && (
            <span className="inline-block mt-1 px-2 py-0.5 bg-gray-800 text-gray-300 rounded text-xs w-fit">
              {album.genre.name}
            </span>
          )}
        </div>

        {/* Track List */}
        <div className="flex flex-col gap-0.5">
          {album.tracks?.map((track) => {
            const isCurrentTrack = currentTrack?.id === track.id;
            const isReady = track.upload_status === "ready";

            return (
              <button
                key={track.id}
                type="button"
                onClick={() => isReady && play(track)}
                disabled={!isReady}
                className={`flex items-center gap-2 p-2 rounded text-left transition ${
                  isCurrentTrack
                    ? "bg-blue-600/20 border border-blue-600"
                    : isReady
                      ? "hover:bg-gray-800 border border-transparent"
                      : "opacity-50 cursor-not-allowed border border-transparent"
                }`}
              >
                <div className="flex items-center justify-center w-6 h-6 rounded-full bg-gray-800/50">
                  {isReady ? (
                    <IconPlayerPlay size={12} className="text-white" />
                  ) : (
                    <span className="text-xs text-gray-300">
                      {track.track_number}
                    </span>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <p
                    className={`text-sm font-medium truncate ${isCurrentTrack ? "text-blue-400" : "text-gray-200"}`}
                  >
                    {track.title}
                  </p>
                </div>
                {track.duration_seconds && (
                  <span className="text-xs text-gray-500 ml-2">
                    {Math.floor(track.duration_seconds / 60)}:
                    {String(track.duration_seconds % 60).padStart(2, "0")}
                  </span>
                )}
                {!isReady && (
                  <span className="text-xs text-gray-500 capitalize ml-2">
                    {track.upload_status}
                  </span>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
