"use client";

import { MusicNote, Pause, PlayArrow } from "@mui/icons-material";
import {
  Box,
  Card,
  Chip,
  List,
  ListItemButton,
  Stack,
  Typography,
} from "@mui/material";
import Image from "next/image";
import { usePlayer } from "@/contexts/PlayerContext";
import type { Album, Track } from "@/types/api";

interface AlbumCardProps {
  album: Album;
}

export function AlbumCard({ album }: AlbumCardProps) {
  const { play, toggle, currentTrack, isPlaying } = usePlayer();

  const handleTrackClick = (track: Track) => {
    const isCurrentTrack = currentTrack?.id === track.id;

    if (isCurrentTrack) {
      toggle();
    } else {
      const trackWithFullData = {
        ...track,
        album: {
          ...album,
          tracks: album.tracks,
        },
        artist: album.artist,
      };
      play(trackWithFullData);
    }
  };

  return (
    <Card sx={{ p: 2 }}>
      <Box
        sx={{ display: "grid", gridTemplateColumns: "auto 1fr 2fr", gap: 2 }}
      >
        {/* Album Cover */}
        <Box sx={{ width: 96, height: 96, position: "relative" }}>
          {album.cover_image_url ? (
            <Image
              src={album.cover_image_url}
              alt={album.title}
              fill
              style={{ objectFit: "cover", borderRadius: 8 }}
            />
          ) : (
            <Box
              sx={{
                width: "100%",
                height: "100%",
                bgcolor: "grey.800",
                borderRadius: 1,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <MusicNote sx={{ fontSize: 40, color: "grey.600" }} />
            </Box>
          )}
        </Box>

        {/* Album Metadata */}
        <Stack justifyContent="center" spacing={0.5}>
          <Typography variant="h6" fontWeight="bold">
            {album.title}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {album.artist?.name}
          </Typography>
          {album.release_year && (
            <Typography variant="caption" color="text.disabled">
              {album.release_year}
            </Typography>
          )}
          {album.genre && <Chip label={album.genre.name} size="small" />}
        </Stack>

        {/* Track List */}
        <List
          disablePadding
          sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}
        >
          {album.tracks
            ?.sort((a, b) => a.track_number - b.track_number)
            .map((track) => {
              const isCurrentTrack = currentTrack?.id === track.id;
              const isCurrentlyPlaying = isCurrentTrack && isPlaying;
              const isReady = track.upload_status === "ready";

              return (
                <ListItemButton
                  key={track.id}
                  onClick={() => isReady && handleTrackClick(track)}
                  disabled={!isReady}
                  selected={isCurrentTrack}
                  sx={{
                    borderRadius: 1,
                    gap: 0.5,
                    opacity: isReady ? 1 : 0.5,
                  }}
                >
                  <Box
                    sx={{
                      width: 24,
                      height: 24,
                      flexShrink: 0,
                    }}
                  >
                    {isReady && (
                      <Box
                        sx={{
                          width: 24,
                          height: 24,
                          borderRadius: "50%",
                          bgcolor: isCurrentlyPlaying
                            ? "primary.main"
                            : "action.hover",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                        }}
                      >
                        {isCurrentlyPlaying ? (
                          <Pause sx={{ fontSize: 12, color: "white" }} />
                        ) : (
                          <PlayArrow sx={{ fontSize: 12 }} />
                        )}
                      </Box>
                    )}
                  </Box>
                  <Typography
                    variant="caption"
                    color="text.secondary"
                    sx={{
                      minWidth: 28,
                      flexShrink: 0,
                    }}
                  >
                    {track.alt_track_number || track.track_number}
                  </Typography>
                  <Typography
                    variant="body2"
                    fontWeight={isCurrentTrack ? "600" : "400"}
                    color={isCurrentTrack ? "primary" : "text.primary"}
                    sx={{
                      flex: 1,
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                    }}
                    noWrap
                  >
                    {track.title}
                  </Typography>
                  {track.duration_seconds && (
                    <Typography variant="caption" color="text.secondary">
                      {Math.floor(track.duration_seconds / 60)}:
                      {String(track.duration_seconds % 60).padStart(2, "0")}
                    </Typography>
                  )}
                  {!isReady && (
                    <Typography
                      variant="caption"
                      color="text.secondary"
                      sx={{ textTransform: "capitalize" }}
                    >
                      {track.upload_status}
                    </Typography>
                  )}
                </ListItemButton>
              );
            })}
        </List>
      </Box>
    </Card>
  );
}
