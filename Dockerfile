FROM golang:1.17.7-alpine3.15 as build

RUN apk add --no-cache make gcc musl-dev

COPY *.go  /build-dir/
COPY go.mod /build-dir/
COPY go.sum /build-dir/
COPY Makefile  /build-dir/
WORKDIR /build-dir
RUN  make build


FROM alpine:3

WORKDIR /app

COPY --from=build build-dir/bin/helm-wrapper helm-wrapper
COPY config.yaml config.yaml

ENV GIN_MODE=release
CMD [ "./helm-wrapper" ]

