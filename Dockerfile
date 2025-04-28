FROM elixir:1.18-alpine AS build

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY . .

ENV MIX_ENV=prod
RUN mix compile
RUN mix release

FROM alpine:3.16

RUN apk add --no-cache libstdc++ ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/elixir_radio ./

RUN mkdir -p /data

VOLUME ["/data"]

CMD ["/app/bin/elixir_radio", "start"]
