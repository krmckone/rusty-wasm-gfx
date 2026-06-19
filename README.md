# Bevy Wasm Application
## 🛠 Prerequisites & Development Options

You can develop this project either inside an isolated **VS Code Dev Container** (recommended) or directly on your **Local Machine**.

### Option A: VS Code Dev Container (Recommended)
This project includes a fully configured production-grade Dev Container. Opening the project in the container automatically installs:
* Rust & Cargo
* The `wasm32-unknown-unknown` compilation target
* `trunk` (the WebAssembly build tool)
* Properly configured persistent Docker volumes for caching dependencies and `target` builds (saving your compilation time).

**To use it:**
1. Ensure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) and VS Code installed.
2. Install the VS Code **Dev Containers** extension.
3. Open this project folder in VS Code, press `Ctrl+Shift+P` (or `Cmd+Shift+P`), and select **Dev Containers: Reopen in Container**.

---

### Option B: Local Machine Setup
If you prefer not to use Docker for development, ensure you have the following installed locally:

1. **Rust:** [Install via rustup](https://rustup.rs/)
2. **WebAssembly Target:** Let the Rust compiler know how to build for the web.
   ```bash
   rustup target add wasm32-unknown-unknown

```

3. **Trunk:** The web build tool used for fast local development and hot-reloading.
```bash
cargo install trunk

```



---

## 🚀 Local Development

Once your environment is ready (either inside the Dev Container terminal or your local terminal), use **Trunk** to build and serve the application. Do not use `cargo run`, as it will attempt to compile a native Linux/desktop binary instead of WebAssembly.

To start the development server:

```bash
trunk serve --address 0.0.0.0

```

*(Note: `--address 0.0.0.0` is required inside the Dev Container so VS Code can securely forward the port to your host machine).*

Navigate to **http://127.0.0.1:8080** in your browser. Any changes saved to `.rs` files will automatically trigger a recompile and refresh your browser tab instantly.

### Graphics Note

Bevy defaults to WebGL2 in the browser. You may see console warnings about unsupported features (like compute shaders). This is normal. If you are experimenting with modern WebGPU features (currently best supported in Chrome), force the WebGL backend by running:

```bash
WGPU_BACKEND=gl trunk serve --address 0.0.0.0

```

---

## 🏗 Deployment Architecture

This project is hosted on an ARM64 Raspberry Pi without exposing any local ports to the public internet.

1. **GitHub Actions:** Cross-compiles the Rust code to Wasm (`trunk build --release`) and packages the final static assets into an ARM64 `nginx:alpine` Docker image on every push to `main`.
2. **Watchtower:** Runs on the Pi, detects when a new image is pushed to the GitHub Container Registry (GHCR), and gracefully restarts the application container.
3. **Cloudflare Tunnel:** Secures ingress traffic, proxying requests directly into the isolated Nginx container without opening port 80/443 on the router.

### Continuous Deployment Setup

1. Define the Pi Environment in `docker-compose.yml`.
2. Run `docker compose up -d` on the Pi.
3. **Pushing Updates:** Simply push or merge your code to the `main` branch. The GitHub Action will build the Wasm binary and publish a new ARM64 Nginx image to GHCR. Within 5 minutes, Watchtower on your Pi will download the new image and silently update the running container.
