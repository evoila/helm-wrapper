FROM alpine:latest

RUN apk add --no-cache \
    git \
    make \
    musl-dev \
    go

# Configure Go
ENV GOROOT=/usr/lib/go \
    GOPATH=/go \
    PATH=/go/bin:$PATH

COPY .  $GOPATH/src/github.com/opskumu/helm-wrapper 
WORKDIR $GOPATH/src/github.com/opskumu/helm-wrapper
RUN  make build


FROM alpine:3  

LABEL io.k8s.description="helm-wrapper" \ 
      io.k8s.display-name="helm-wrapper"

RUN echo "uploadPath: /tmp/charts" >/config.yaml
COPY --from=0 /go/src/github.com/opskumu/helm-wrapper/bin/helm-wrapper /helm-wrapper

CMD [ "/helm-wrapper" ]
