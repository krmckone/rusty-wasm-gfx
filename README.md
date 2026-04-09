# Bevy Wasm Application

## 🛠 Prerequisites

Before running this project locally, ensure you have the following installed:

1. **Rust:** [Install via rustup](https://rustup.rs/)
2. **WebAssembly Target:** Let the Rust compiler know how to build for the web.
   ```bash
   rustup target add wasm32-unknown-unknown

Trunk: The web build tool used for fast local development and hot-reloading.

```bash
cargo install trunk
```

## Local Development
For local development, we bypass Docker and use trunk. It automatically compiles the Rust code to Wasm, injects it into index.html, and serves it with instant hot-reloading.

To start the development server:
```bash
trunk serve
```
Navigate to http://127.0.0.1:8080 in your browser.

Any changes saved to .rs files will automatically trigger a recompile and refresh your browser tab.

Graphics Note: Bevy defaults to WebGL2 in the browser. You may see console warnings about unsupported features (like compute shaders). This is normal. If you are experimenting with modern WebGPU features (currently best supported in Chrome), force the backend by running:
```bash
WGPU_BACKEND=gl trunk serve
```

## Deployment Architecture
This project is hosted on an ARM64 Raspberry Pi without exposing any local ports to the public internet.

GitHub Actions: Cross-compiles the Rust code to Wasm and packages it into an ARM64 nginx:alpine Docker image on every push to main.

Watchtower: Runs on the Pi, detects when a new image is pushed to the GitHub Container Registry (GHCR), and gracefully restarts the application.

Cloudflare Tunnel: Secures ingress traffic, proxying requests directly into the isolated Nginx container.

## Continuous Deployment Setup
1. The Pi Environment (docker-compose.yml)
2. `docker compose up -d`
3. Pushing Updates
Simply push or merge your code to the main branch.
The GitHub Action will build the Wasm binary and publish a new ARM64 Nginx image to GHCR.
Within 5 minutes, Watchtower on your Pi will download the new image and silently update the running container.
