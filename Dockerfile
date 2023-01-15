ARG BILDER_IMAGE="elixir:alpine"
ARG RUNNER_IMAGE="alpine:3.17"

FROM elixir:alpine AS builder

ENV MIX_ENV="prod"
WORKDIR /app

RUN apk update && \
    apk add --no-cache --update git build-base

RUN mix do local.hex --force, local.rebar --force

COPY mix.exs ./
COPY config config
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY lib lib
RUN mix compile

COPY rel rel
RUN mix release

FROM ${RUNNER_IMAGE}

WORKDIR /app

RUN apk update && \
    apk add --no-cache --update build-base ncurses

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY --from=builder /app/_build/prod/rel ./

CMD /app/protohackers/bin/protohackers start
