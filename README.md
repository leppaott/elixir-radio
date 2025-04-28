# Elixir-radio

Implement audio streaming backend on Elixir using HLS audio.

## TODO

- actual file structure
- fix hot-reloading / prod build
- PG / segmentation support

## File structure

```console
/data/
├── 1/                  # Stream ID
│   ├── segments/       # Directory for TS segments
│   │   ├── segment0.ts
│   │   ├── segment1.ts
│   │   └── ...
│   └── audio_pl.m3u8   # Manifest file
```

## Elixir help

```bash
mix deps.get
mix compile
```
