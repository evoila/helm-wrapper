OM alpine:3 as build

RUN apk add --no-cache \
    git \
    make \
    musl-dev \
    go

# Configure Go
ENV GOROOT=/usr/lib/go \
    GOPATH=/go \
    PATH=/go/bin:$PATH

COPY .  $GOPATH/
WORKDIR $GOPATH
RUN  make build


FROM alpine:3

ENV ADD_CA_PATH=/app/customca

LABEL io.k8s.description="helm-wrapper" \
      io.k8s.display-name="helm-wrapper"

RUN apk add --no-cache sudo

RUN addgroup -g 1001 appuser && \
    adduser -H -D -u 1001 -G appuser appuser && \
    mkdir -p /app/customca /app/helper && \
    touch /app/customca/dummy.crt && \
    echo "uploadPath: /tmp/charts" >/app/config.yaml && \
    echo -e '#!/bin/sh\ncat $(find $ADD_CA_PATH -name *.crt) >> /etc/ssl/certs/ca-certificates.crt\nrm $0' >/app/helper/add_ca.sh && \
    echo -e '#!/bin/sh\nrm -rf /usr/bin/sudo /etc/sudoers' >/app/helper/rm_sudo.sh && \
    echo "appuser ALL=(ALL) NOPASSWD: /app/helper/add_ca.sh, /app/helper/rm_sudo.sh" >/etc/sudoers && \
    echo -e '#!/bin/sh\ncd /app\nsudo /app/helper/add_ca.sh\nsudo /app/helper/rm_sudo.sh\n$@' >/app/entrypoint.sh && \
    chmod 0755 /app/entrypoint.sh /app/helper/add_ca.sh /app/helper/rm_sudo.sh

COPY --from=build /go/bin/helm-wrapper /app/helm-wrapper

USER appuser


ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD [ "./helm-wrapper" ]

