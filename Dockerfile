FROM rust:slim AS builder

RUN apt-get update && apt-get install -y curl pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
RUN rustup target add wasm32-unknown-unknown
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        TRUNK_ARCH="x86_64-unknown-linux-gnu"; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        TRUNK_ARCH="aarch64-unknown-linux-musl"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    curl -L "https://github.com/trunk-rs/trunk/releases/latest/download/trunk-${TRUNK_ARCH}.tar.gz" | tar -xzf - -C /usr/local/bin/
WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY index.html ./
RUN trunk build --release

FROM nginx:alpine

COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
