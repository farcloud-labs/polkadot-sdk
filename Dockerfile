FROM rust:1.80.0 AS builder

RUN apt update && apt install -y make clang pkg-config libssl-dev protobuf-compiler build-essential git curl llvm make
RUN rustup  install nightly && \
	rustup default nightly && \
    rustup component add rust-src && \
    rustup target add wasm32-unknown-unknown

WORKDIR /substrate-node
COPY . /substrate-node
RUN apt update && apt install -y ca-certificates && \
	cargo build --release -p staging-node-cli


# This is the 2nd stage: a very small image where we copy the substrate-node binary."
FROM docker.io/library/ubuntu:22.04
LABEL description="smt node" \
	io.parity.image.type="builder" \
	io.parity.image.authors="yanoctavian" \
	io.parity.image.vendor="yanoctavian" 
	# io.parity.image.description="substrate-node is a next-generation framework for blockchain innovation 🚀" \
	# io.parity.image.source="https://github.com/paritytech/polkadot-sdk/blob/${VCS_REF}/substrate-node/docker/substrate-node_builder.Dockerfile" \
	# io.parity.image.documentation="https://github.com/paritytech/polkadot-sdk"

COPY --from=builder /substrate-node/target/release/substrate-node /usr/local/bin
# COPY --from=builder /substrate-node/target/release/subkey /usr/local/bin
# COPY --from=builder /substrate-node/target/release/node-template /usr/local/bin
# COPY --from=builder /substrate-node/target/release/chain-spec-builder /usr/local/bin

RUN useradd -m -u 1000 -U -s /bin/sh -d /substrate-node substrate-node && \
	mkdir -p /data /substrate-node/.local/share/substrate-node && \
	chown -R substrate-node:substrate-node /data && \
	ln -s /data /substrate-node/.local/share/substrate-node && \
# Sanity checks
	ldd /usr/local/bin/substrate-node && \
# unclutter and minimize the attack surface
	rm -rf /usr/bin /usr/sbin && \
	/usr/local/bin/substrate-node --version

USER substrate-node
EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]
