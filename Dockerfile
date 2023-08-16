# syntax=docker/dockerfile:1
FROM golang:1.21-bullseye@sha256:4a2ad9f7dc6cde77e43fee49403ba98e2789af5602fcd2ccd072b79bbac75507 AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./ ./
RUN make build

FROM debian:bullseye-slim@sha256:61386e11b5256efa33823cbfafd668dd651dbce810b24a8fb7b2e32fa7f65a85
WORKDIR /app

RUN groupadd -g 1000 app && useradd -u 1000 -g app app

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER app
COPY --from=build /app/msime2mac ./
CMD ["./msime2mac"]
