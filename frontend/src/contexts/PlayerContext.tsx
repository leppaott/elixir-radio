"use client";

import { createContext, useContext, useRef, useState } from "react";
import { getTracksUrl } from "@/lib/api";
import type { Track } from "@/types/api";

interface PlayerContextType {
  currentTrack: Track | null;
  isPlaying: boolean;
  play: (track: Track) => Promise<void>;
  pause: () => void;
  toggle: () => void;
  next: () => void;
  prev: () => void;
  audioRef: React.RefObject<HTMLAudioElement>;
}

const PlayerContext = createContext<PlayerContextType | undefined>(undefined);

export function PlayerProvider({ children }: { children: React.ReactNode }) {
  const [currentTrack, setCurrentTrack] = useState<Track | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const audioRef = useRef<HTMLAudioElement>(null);

  const play = async (track: Track) => {
    if (!track.stream_url && track.upload_status === "ready") {
      try {
        const response = await fetch(getTracksUrl(track.id));
        const fullTrack = await response.json();
        if (fullTrack.stream_url) {
          // Preserve album.tracks for prev/next navigation
          setCurrentTrack({
            ...fullTrack,
            album: track.album,
            artist: track.artist,
          });
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

  const next = () => {
    if (!currentTrack?.album?.tracks) return;

    const tracks = currentTrack.album.tracks.sort(
      (a, b) => a.track_number - b.track_number,
    );
    const currentIndex = tracks.findIndex((t) => t.id === currentTrack.id);

    for (let i = currentIndex + 1; i < tracks.length; i++) {
      if (tracks[i].upload_status === "ready") {
        play({
          ...tracks[i],
          album: currentTrack.album,
          artist: currentTrack.artist,
        });
        return;
      }
    }
  };

  const prev = () => {
    if (!currentTrack?.album?.tracks) return;

    const tracks = currentTrack.album.tracks.sort(
      (a, b) => a.track_number - b.track_number,
    );
    const currentIndex = tracks.findIndex((t) => t.id === currentTrack.id);

    for (let i = currentIndex - 1; i >= 0; i--) {
      if (tracks[i].upload_status === "ready") {
        play({
          ...tracks[i],
          album: currentTrack.album,
          artist: currentTrack.artist,
        });
        return;
      }
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
        next,
        prev,
        audioRef: audioRef as React.RefObject<HTMLAudioElement>,
      }}
    >
      {children}
      {currentTrack && (
        <audio
          ref={audioRef}
          src={currentTrack.stream_url}
          onPlay={() => setIsPlaying(true)}
          onPause={() => setIsPlaying(false)}
          autoPlay={isPlaying}
        >
          <track kind="captions" label="" />
        </audio>
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
