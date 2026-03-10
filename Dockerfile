ARG ARCH=aarch64
ARG ACAP_SDK_VERSION=12.9.0
ARG SDK_IMAGE=docker.io/axisecp/acap-native-sdk
ARG STAGE_DIR=/opt/stage
ARG RESVG_VERSION=0.45.1
ARG RUST_VERSION=1.94

FROM docker.io/rust:$RUST_VERSION-alpine AS rust-builder-aarch64
ENV RUST_TARGET=aarch64-unknown-linux-musl

FROM docker.io/rust:$RUST_VERSION-alpine AS rust-builder-armv7hf
ENV RUST_TARGET=armv7-unknown-linux-musleabihf

# hadolint ignore=DL3006
FROM rust-builder-$ARCH AS rust-builder
ARG STAGE_DIR
ARG RESVG_VERSION
ARG RESVG_DIR=/usr/local/src/resvg
# hadolint ignore=DL3018
RUN apk add --no-cache \
        bash \
        build-base \
        xz \
        zig
RUN cargo install --locked cargo-zigbuild
RUN rustup target add "$RUST_TARGET"
WORKDIR "$STAGE_DIR"
WORKDIR "$RESVG_DIR"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3047
RUN wget -O- https://github.com/linebender/resvg/releases/download/v$RESVG_VERSION/resvg-$RESVG_VERSION.tar.xz | tar -xJ --strip-components=1
RUN RUSTFLAGS='-C strip=symbols' cargo zigbuild --release --locked --manifest-path crates/usvg/Cargo.toml --target "$RUST_TARGET" && \
    cp "target/$RUST_TARGET/release/usvg" "$STAGE_DIR/"

FROM $SDK_IMAGE:$ACAP_SDK_VERSION-$ARCH AS builder
ARG STAGE_DIR
ARG ARCH
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-liberation
WORKDIR "$STAGE_DIR"/fonts
RUN cp /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf .
WORKDIR "$STAGE_DIR"
COPY manifest.json \
     findwind \
     LICENSE \
     ./
COPY --from=rust-builder "$STAGE_DIR/usvg" ./
RUN . /opt/axis/acapsdk/environment-setup* && \
    echo all: > Makefile && \
    acap-build -a usvg -a fonts .

FROM scratch
ARG STAGE_DIR
COPY --from=builder "$STAGE_DIR"/*eap "$STAGE_DIR"/*LICENSE.txt /
