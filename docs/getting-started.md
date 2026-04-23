# Getting Started

This guide walks you from a fresh machine to running opencode inside a container with `roninyolo`.

---

## Prerequisites

You need:

- **Bash 3.2+** — present by default on macOS and all Linux distributions
- **Docker** (or Podman) — installed and running
  - [Install Docker Engine](https://docs.docker.com/engine/install/)
  - [Install Podman](https://podman.io/docs/installation) (rootless works too)

Verify Docker is working:

```bash
docker run --rm hello-world
```

---

## Step 1 — Install roninyolo

### Option A: Download the script (recommended for most users)

```bash
curl -fsSL https://github.com/your-org/roninyolo/releases/latest/download/roninyolo \
  -o ~/.local/bin/roninyolo
chmod +x ~/.local/bin/roninyolo
```

Make sure `~/.local/bin` is in your `PATH`. If it isn't, add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Option B: Clone and symlink (for development or staying on latest)

```bash
git clone https://github.com/your-org/roninyolo.git ~/roninyolo
ln -s ~/roninyolo/bin/roninyolo ~/.local/bin/roninyolo
```

### Verify the install

```bash
roninyolo version
# roninyolo 0.1.0
```

---

## Step 2 — Get an opencode container image

You have two options: pull a pre-built image or build one locally.

### Option A: Build the bundled Dockerfile

```bash
cd ~/roninyolo   # or wherever you cloned the repo

# Tell roninyolo where the Dockerfile is and which image names to use
cat > ~/.config/roninyolo.conf <<'EOF'
RY_DOCKERFILE="docker/Dockerfile"
# RY_BASE_IMAGE is the base image the Dockerfile builds FROM
RY_BASE_IMAGE="debian:12-slim"
# RY_IMAGE is the tag applied to the built image (and used by docker run)
RY_IMAGE="roninyolo/opencode:local"
EOF

roninyolo build
```

This builds a `debian:12-slim`-based image with opencode installed, tagged as `roninyolo/opencode:local`.

### Option B: Use a pre-built image

If your organisation publishes an opencode image, point `RY_IMAGE` at it:

```bash
cat > ~/.config/roninyolo.conf <<'EOF'
RY_IMAGE="ghcr.io/your-org/opencode:latest"
EOF
```

No build step needed — Docker pulls the image automatically on first run.

---

## Step 3 — Configure opencode credentials

opencode reads its config (API keys, model preferences) from `~/.config/opencode` by default. `roninyolo` mounts that directory read-only into the container.

Create the host-side config directory and add your API key:

```bash
mkdir -p ~/.config/opencode
```

Then follow the [opencode setup guide](https://opencode.ai/docs) to write your config file there. A minimal example:

```bash
cat > ~/.config/opencode/config.json <<'EOF'
{
  "provider": "anthropic",
  "model": "claude-sonnet-4-5"
}
EOF
```

You will also need to pass your API key into the container. Add it to your user config:

```bash
cat >> ~/.config/roninyolo.conf <<'EOF'
RY_ENV_VARS=(
  "ANTHROPIC_API_KEY=sk-ant-..."
)
EOF
```

> **Security note:** The config directory is mounted `:ro` — the container can read your credentials but cannot modify them.

---

## Step 4 — Run opencode

Navigate to a project and launch:

```bash
cd ~/my-project
roninyolo
```

`roninyolo` mounts your current directory at `/work` inside the container and runs `opencode`. When you exit opencode, the container stops automatically.

---

## What roninyolo runs under the hood

For reference, the equivalent raw `docker run` command is:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$HOME/.config/opencode:/root/.config/opencode:ro" \
  -v "$PWD:/work" \
  -w /work \
  -e "ANTHROPIC_API_KEY=sk-ant-..." \
  roninyolo/opencode:local opencode
```

---

## Common variations

### Run a different command

Drop into a shell inside the container to explore or debug:

```bash
roninyolo bash
```

Run a one-off script inside the container environment:

```bash
roninyolo python3 /work/scripts/check.py
```

### Per-project config

Create `.roninyolo.conf` in your project root to override settings for that project only:

```bash
cat > ~/my-project/.roninyolo.conf <<'EOF'
# Use a project-specific image
RY_IMAGE="myregistry.local/opencode:v2"

# Mount shared reference data read-only
RY_ADDITIONAL_VOLUMES=("/data/reference:/ref:ro")
EOF
```

From that project, just run `roninyolo` — the project config is loaded automatically.

### Use Podman instead of Docker

```bash
cat >> ~/.config/roninyolo.conf <<'EOF'
RY_DOCKER_BIN="podman"
EOF
```

Everything else works the same way.

---

## Next steps

- [`docs/configuration.md`](configuration.md) — full reference for all `RY_*` variables
- [`docs/opencode.md`](opencode.md) — opencode-specific wiring details
- [`examples/.roninyolo.conf`](../examples/.roninyolo.conf) — annotated example project config
