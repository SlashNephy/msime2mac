# syntax=docker/dockerfile:1@sha256:a57df69d0ea827fb7266491f2813635de6f17269be881f696fbfdf2d83dda33e
FROM golang:1.22-bullseye@sha256:72885e2245d6bcc63af0538043c63454878a22733587af87a4cfb12268d03baf AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./ ./
RUN make build

FROM debian:bullseye-slim@sha256:715354035496a48b9c4c8f146a6f751de70449913773038776eb1f3d01c93989
WORKDIR /app

RUN groupadd -g 1000 app && useradd -u 1000 -g app app

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER app
COPY --from=build /app/msime2mac ./
CMD ["./msime2mac"]
