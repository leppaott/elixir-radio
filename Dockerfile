FROM elixir:1.19-alpine AS build

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY . .

ENV MIX_ENV=prod
RUN mix compile
RUN mix release

FROM alpine:3.23

# Install runtime dependencies
RUN apk add --no-cache \
    libstdc++ \
    ncurses-libs \
    ffmpeg

WORKDIR /app

COPY --from=build /app/_build/prod/rel/elixir_radio ./

RUN mkdir -p /data

VOLUME ["/data"]

CMD ["/app/bin/elixir_radio", "start"]
