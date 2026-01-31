"use client";

import {
  IconPlayerPause,
  IconPlayerPlay,
  IconPlayerSkipBack,
  IconPlayerSkipForward,
} from "@tabler/icons-react";
import Image from "next/image";
import { usePlayer } from "@/contexts/PlayerContext";

export function AudioPlayer() {
  const { currentTrack, isPlaying, toggle, audioRef } = usePlayer();

  if (!currentTrack) {
    return (
      <div className="flex items-center justify-center p-4 text-gray-400 text-sm">
        <p>No track playing</p>
      </div>
    );
  }

  const handleSeek = (seconds: number) => {
    if (audioRef?.current) {
      audioRef.current.currentTime += seconds;
    }
  };

  return (
    <div className="flex items-center gap-4 p-4 bg-gray-950">
      {/* Compact Album Art */}
      {currentTrack.album?.cover_image_url ? (
        <div className="w-14 h-14 relative">
          <Image
            src={currentTrack.album.cover_image_url}
            alt={currentTrack.album.title}
            fill
            className="rounded object-cover"
          />
        </div>
      ) : (
        <div className="w-14 h-14 bg-gray-800 rounded flex items-center justify-center">
          <span className="text-gray-500 text-xl">♪</span>
        </div>
      )}

      {/* Track Info */}
      <div className="flex-1 min-w-0">
        <h3 className="text-sm font-semibold text-white truncate">
          {currentTrack.title}
        </h3>
        <p className="text-xs text-gray-400 truncate">
          {currentTrack.artist?.name} · {currentTrack.album?.title}
        </p>
      </div>

      {/* Compact Controls */}
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => handleSeek(-10)}
          className="p-1.5 hover:bg-gray-800 rounded transition"
          title="Rewind 10s"
        >
          <IconPlayerSkipBack size={18} />
        </button>

        <button
          type="button"
          onClick={toggle}
          className="p-2 bg-blue-600 hover:bg-blue-700 rounded transition"
        >
          {isPlaying ? (
            <IconPlayerPause size={20} />
          ) : (
            <IconPlayerPlay size={20} />
          )}
        </button>

        <button
          type="button"
          onClick={() => handleSeek(10)}
          className="p-1.5 hover:bg-gray-800 rounded transition"
          title="Forward 10s"
        >
          <IconPlayerSkipForward size={18} />
        </button>
      </div>
    </div>
  );
}
