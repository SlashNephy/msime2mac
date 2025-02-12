# syntax=docker/dockerfile:1@sha256:93bfd3b68c109427185cd78b4779fc82b484b0b7618e36d0f104d4d801e66d25
FROM golang:1.23-bullseye@sha256:80eb3147ef40b58d527d9c2e634b1a79a750aee09de6f973844db38b33f0550b AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./ ./
RUN make build

FROM debian:bullseye-slim@sha256:e831d9a884d63734fe3dd9c491ed9a5a3d4c6a6d32c5b14f2067357c49b0b7e1
WORKDIR /app

RUN groupadd -g 1000 app && useradd -u 1000 -g app app

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER app
COPY --from=build /app/msime2mac ./
CMD ["./msime2mac"]
