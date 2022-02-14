FROM golang:1.17.7-alpine3.15 as build

RUN apk add --no-cache make gcc musl-dev

COPY *.go  /build-dir/
COPY go.mod /build-dir/
COPY Makefile  /build-dir/
WORKDIR /build-dir
RUN  make build


FROM alpine:3

ENV ADD_CA_PATH=/app/customca

LABEL io.k8s.description="helm-wrapper" \
      io.k8s.display-name="helm-wrapper"

RUN apk add --no-cache sudo

COPY docker/dummy.crt /app/customca/dummy.crt
COPY docker/add_ca.sh /app/helper/add_ca.sh
COPY docker/config.yaml /app/config.yaml
COPY docker/rm_sudo.sh /app/helper/rm_sudo.sh
COPY docker/sudoers /etc/sudoers
COPY docker/entrypoint.sh /app/entrypoint.sh

RUN addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser && \
    chmod 0755 /app/entrypoint.sh /app/helper/add_ca.sh /app/helper/rm_sudo.sh


COPY --from=build build-dir/bin/helm-wrapper /app/helm-wrapper

USER appuser


ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD [ "./helm-wrapper" ]

