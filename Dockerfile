FROM debian:bookworm AS build-env

ARG RUBY_VERSION=3.4.2
ARG WORKDIR=/app

WORKDIR ${WORKDIR}

RUN mkdir -p ${WORKDIR}

RUN apt update && apt upgrade -y
RUN apt install -y build-essential curl gzip tar libyaml-dev zlib1g-dev libssl-dev libffi-dev libgmp-dev rust-all libjemalloc-dev

RUN curl -sSL https://cache.ruby-lang.org/pub/ruby/3.4/ruby-${RUBY_VERSION}.tar.gz -o /tmp/ruby-${RUBY_VERSION}.tar.gz

RUN cd /tmp && tar -xf ruby-${RUBY_VERSION}.tar.gz

RUN cd /tmp/ruby-${RUBY_VERSION} && \
    ./configure \
    --enable-yjit \
    --with-gmp \
    --with-jemalloc \
    --with-static-linked-ext \
    --prefix=${WORKDIR} && \
    make -j4 && \
    make install

FROM gcr.io/distroless/cc

COPY --from=build-env /app /
WORKDIR /

ENTRYPOINT [ "ruby" ]