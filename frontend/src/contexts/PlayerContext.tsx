"use client";

import { createContext, useContext, useRef, useState } from "react";
import type { Track } from "@/types/api";

interface PlayerContextType {
  currentTrack: Track | null;
  isPlaying: boolean;
  play: (track: Track) => Promise<void>;
  pause: () => void;
  toggle: () => void;
  audioRef: React.RefObject<HTMLAudioElement>;
}

const PlayerContext = createContext<PlayerContextType | undefined>(undefined);

export function PlayerProvider({ children }: { children: React.ReactNode }) {
  const [currentTrack, setCurrentTrack] = useState<Track | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const audioRef = useRef<HTMLAudioElement>(null);

  const play = async (track: Track) => {
    // If track doesn't have stream_url, fetch full track details
    if (!track.stream_url && track.upload_status === "ready") {
      try {
        const response = await fetch(`/api/tracks/${track.id}`);
        const fullTrack = await response.json();
        if (fullTrack.stream_url) {
          setCurrentTrack(fullTrack);
          setIsPlaying(true);
          return;
        }
      } catch (error) {
        console.error("Failed to fetch track details:", error);
      }
    }

    if (currentTrack?.id !== track.id) {
      setCurrentTrack(track);
      setIsPlaying(true);
    } else {
      audioRef.current?.play();
      setIsPlaying(true);
    }
  };

  const pause = () => {
    audioRef.current?.pause();
    setIsPlaying(false);
  };

  const toggle = () => {
    if (isPlaying) {
      pause();
    } else if (currentTrack) {
      play(currentTrack);
    }
  };

  return (
    <PlayerContext.Provider
      value={{
        currentTrack,
        isPlaying,
        play,
        pause,
        toggle,
        audioRef: audioRef as React.RefObject<HTMLAudioElement>,
      }}
    >
      {children}
      {currentTrack && (
        // biome-ignore lint/a11y/useMediaCaption: Music player doesn't require captions
        <audio
          ref={audioRef}
          src={currentTrack.stream_url}
          onPlay={() => setIsPlaying(true)}
          onPause={() => setIsPlaying(false)}
          autoPlay={isPlaying}
        />
      )}
    </PlayerContext.Provider>
  );
}

export function usePlayer() {
  const context = useContext(PlayerContext);
  if (!context) {
    throw new Error("usePlayer must be used within PlayerProvider");
  }
  return context;
}
