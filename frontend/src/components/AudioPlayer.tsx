"use client";

import {
  MusicNote,
  Pause,
  PlayArrow,
  SkipNext,
  SkipPrevious,
} from "@mui/icons-material";
import {
  Box,
  IconButton,
  LinearProgress,
  Stack,
  Typography,
} from "@mui/material";
import Image from "next/image";
import { useEffect, useState } from "react";
import { usePlayer } from "@/contexts/PlayerContext";

export function AudioPlayer() {
  const { currentTrack, isPlaying, toggle, next, prev, audioRef } = usePlayer();
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  useEffect(() => {
    const audio = audioRef?.current;
    if (!audio) return;

    const updateTime = () => setCurrentTime(audio.currentTime);
    const updateDuration = () => setDuration(audio.duration);

    audio.addEventListener("timeupdate", updateTime);
    audio.addEventListener("loadedmetadata", updateDuration);
    audio.addEventListener("durationchange", updateDuration);

    // Initialize duration from track metadata if audio duration not available yet
    if (currentTrack?.duration_seconds) {
      setDuration(currentTrack.duration_seconds);
    }

    return () => {
      audio.removeEventListener("timeupdate", updateTime);
      audio.removeEventListener("loadedmetadata", updateDuration);
      audio.removeEventListener("durationchange", updateDuration);
    };
  }, [audioRef, currentTrack]);

  const handleProgressClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!audioRef?.current || !duration) return;
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const percentage = x / rect.width;
    audioRef.current.currentTime = percentage * duration;
  };

  const formatTime = (seconds: number) => {
    if (!seconds || Number.isNaN(seconds)) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${String(secs).padStart(2, "0")}`;
  };

  if (!currentTrack) {
    return (
      <Stack spacing={2} alignItems="center" sx={{ p: 3 }}>
        <Box
          sx={{
            width: 192,
            height: 192,
            bgcolor: "grey.800",
            borderRadius: 2,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <MusicNote sx={{ fontSize: 80, color: "grey.600" }} />
        </Box>
        <Typography variant="body2" color="text.secondary">
          No track playing
        </Typography>
      </Stack>
    );
  }

  return (
    <Stack spacing={2} alignItems="center" sx={{ p: 3 }}>
      {/* Album Art */}
      {currentTrack.album?.cover_image_url ? (
        <Box
          sx={{
            width: 192,
            height: 192,
            position: "relative",
            borderRadius: 2,
            overflow: "hidden",
            boxShadow: 3,
          }}
        >
          <Image
            src={currentTrack.album.cover_image_url}
            alt={currentTrack.album.title}
            fill
            style={{ objectFit: "cover" }}
          />
        </Box>
      ) : (
        <Box
          sx={{
            width: 192,
            height: 192,
            bgcolor: "grey.800",
            borderRadius: 2,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            boxShadow: 3,
          }}
        >
          <MusicNote sx={{ fontSize: 80, color: "grey.600" }} />
        </Box>
      )}

      {/* Progress Bar */}
      <Box sx={{ width: "100%" }}>
        <Box onClick={handleProgressClick} sx={{ cursor: "pointer", py: 1 }}>
          <LinearProgress
            variant="determinate"
            value={duration ? (currentTime / duration) * 100 : 0}
            sx={{
              height: 6,
              borderRadius: 1,
              "& .MuiLinearProgress-bar": {
                transition: "none",
              },
            }}
          />
        </Box>
        <Stack direction="row" justifyContent="space-between" sx={{ mt: 0.5 }}>
          <Typography variant="caption" color="text.secondary">
            {formatTime(currentTime)}
          </Typography>
          <Typography variant="caption" color="text.secondary">
            {formatTime(duration)}
          </Typography>
        </Stack>
      </Box>

      {/* Track Info */}
      <Box sx={{ textAlign: "center", width: "100%" }}>
        <Typography variant="body1" fontWeight="600" noWrap sx={{ px: 1 }}>
          {currentTrack.title}
        </Typography>
        <Typography
          variant="body2"
          color="text.secondary"
          noWrap
          sx={{ px: 1 }}
        >
          {currentTrack.album?.artist?.name}
        </Typography>
        <Typography
          variant="caption"
          color="text.disabled"
          noWrap
          sx={{ px: 1 }}
        >
          {currentTrack.album?.title}
        </Typography>
      </Box>

      {/* Controls */}
      <Stack direction="row" spacing={1} alignItems="center">
        <IconButton onClick={prev} size="large" title="Previous track">
          <SkipPrevious />
        </IconButton>

        <IconButton
          onClick={toggle}
          color="primary"
          size="large"
          sx={{
            bgcolor: "primary.main",
            color: "white",
            "&:hover": { bgcolor: "primary.dark" },
          }}
        >
          {isPlaying ? <Pause /> : <PlayArrow />}
        </IconButton>

        <IconButton onClick={next} size="large" title="Next track">
          <SkipNext />
        </IconButton>
      </Stack>
    </Stack>
  );
}
