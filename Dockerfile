ARG ELIXIR_VERSION=1.20.0
ARG OTP_VERSION=29.0.1
ARG DEBIAN_VERSION=trixie-20260518-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# ── Build ──
FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force \
  && mix local.rebar --force

ENV MIX_ENV=prod

# ── Dependencies (cached until mix.lock or compile-time config changes) ──
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

RUN mix assets.setup

COPY priv priv
COPY lib lib
COPY assets assets
RUN mix assets.deploy

RUN mix compile

COPY config/runtime.exs config/

RUN mix release

# ── Production ──
FROM ${RUNNER_IMAGE} AS final

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV=prod

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/averziano ./

ENV PHX_SERVER=true
ENV PORT=4000
EXPOSE 4000

USER nobody

CMD ["/bin/sh", "-c", "/app/bin/averziano eval 'Averziano.Release.migrate()' && exec /app/bin/averziano start"]
