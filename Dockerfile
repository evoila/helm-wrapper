FROM golang:1.20-alpine3.18 as build

RUN apk add --no-cache make gcc musl-dev

COPY *.go go.mod go.sum  /build-dir/
COPY Makefile  /build-dir/
WORKDIR /build-dir
RUN  make build


FROM alpine:3

WORKDIR /app

COPY --from=build build-dir/bin/helm-wrapper helm-wrapper
COPY config.yaml config.yaml

ENV GIN_MODE=release
CMD [ "./helm-wrapper" ]
