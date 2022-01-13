FROM alpine:latest

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
  && apk add --no-cache \
  git \
  make \
  musl-dev \
  go
#   paxmark bison flex texinfo gawk zip gmp-dev mpfr-dev mpc1-dev zlib-dev libucontext-dev linux-headers isl-dev gcc-gnat-bootstrap

# Configure Go
ENV GOROOT=/usr/lib/go \
    GOPATH=/go \
    PATH=/go/bin:$PATH

RUN  mkdir -p ${GOPATH}/src ${GOPATH}/bin \
  && git clone https://github.com/opskumu/helm-wrapper $GOPATH/src/github.com/opskumu/helm-wrapper \
  && cd $GOPATH/src/github.com/opskumu/helm-wrapper \
  && make build \
  && make build-linux


FROM alpine:3  

LABEL io.k8s.description="helm-wrapper" \ 
      io.k8s.display-name="heml-wrapper"

COPY --from=0 /go/src/github.com/opskumu/helm-wrapper/bin/helm-wrapper /helm-wrapper
COPY --from=0  /go/src/github.com/opskumu/helm-wrapper/config-example.yaml /config.yaml

CMD [ "/helm-wrapper" ]
