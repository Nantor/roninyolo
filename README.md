# roninyolo

![A stylized logo shows a ninja-like figure in mid-jump between two rocky cliffs, moving from left to right with a strong sense of motion and determination. The figure wears loose clothing and a wide hat, with their face mostly hidden except for bright eyes, giving a focused and mysterious feel. On the left cliff, there’s a small glowing box marked “AI,” with abstract symbols rising from it, suggesting ideas or digital activity. On the right cliff, a wooden sign reads “YOLO,” marking the destination. In the background, a large low sun sits behind distant mountains and a traditional gate shape, adding depth to the scene, while a few birds fly overhead. At the bottom, the name “RONIN YOLO” appears in large, rough, hand-painted-style lettering, reinforcing a bold, playful theme of taking a leap from AI into action.](assets/logo.png)

> *Note: The image is AI-generated with DALL·E.*

A Bash CLI wrapper that runs [opencode](https://opencode.ai) (or any interactive CLI tool) inside a container, with your host config and working directory mounted automatically.

## What it does

`roninyolo` solves a simple problem: you want to run an AI coding agent like opencode in an isolated container, but you need the tool to see your project files and your existing config (API keys, settings). It handles the `docker run` boilerplate — volume mounts, user mapping, working directory — so you don't have to.

Key properties:

- Your current directory is mounted read-write into the container — the tool sees and edits your real files.
- Your config directory is mounted read-only — credentials are available but cannot be modified by the container.
- File ownership is preserved: the container runs as your host `uid:gid` by default, so created files belong to you.
- Layered config: system → user → project, all plain Bash files.

## Quickstart

### 1. Install

Copy the script somewhere on your `PATH`:

```bash
curl -fsSL https://github.com/your-org/roninyolo/releases/latest/download/roninyolo \
  -o ~/.local/bin/roninyolo
chmod +x ~/.local/bin/roninyolo
```

Or clone and symlink:

```bash
git clone https://github.com/your-org/roninyolo.git
ln -s "$PWD/roninyolo/bin/roninyolo" ~/.local/bin/roninyolo
```

### 2. Configure

Create a user config file (optional — defaults work for a quick start):

```bash
mkdir -p ~/.config
cat > ~/.config/roninyolo.conf <<'EOF'
RY_IMAGE="ghcr.io/your-org/opencode:latest"
RY_HOST_CONFIG_DIR="$HOME/.config/opencode"
RY_CONTAINER_CONFIG_DIR="/root/.config/opencode"
EOF
```

### 3. Run opencode

```bash
cd ~/my-project
roninyolo
```

This is equivalent to:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$HOME/.config/opencode:/root/.config/opencode:ro" \
  -v "$PWD:/work" \
  -w /work \
  ghcr.io/your-org/opencode:latest opencode
```

## Commands

```bash
roninyolo [run] [CMD ...]   Run the container (default CMD: opencode)
roninyolo build             Build the image from RY_DOCKERFILE
roninyolo help              Show help
```

## Configuration

Config is read from plain Bash files, loaded in this order (later files override earlier ones):

| File                           | Scope       |
| ------------------------------ | ----------- |
| `/etc/roninyolo.conf`          | system-wide |
| `$HOME/.config/roninyolo.conf` | per-user    |
| `$PWD/.roninyolo.conf`         | per-project |

See [`docs/configuration.md`](docs/configuration.md) for a full reference of all variables.

## Examples

### Run opencode (default)

```bash
cd ~/my-project
roninyolo
```

### Run an arbitrary command

```bash
roninyolo bash
roninyolo python3 script.py
```

### Run with explicit `run` subcommand

```bash
roninyolo run opencode
```

### Build the image

Set `RY_DOCKERFILE` in your config, then:

```bash
roninyolo build
```

### Per-project config

Create `.roninyolo.conf` in your project root:

```bash
# .roninyolo.conf
RY_IMAGE="myregistry.local/opencode:v2"
RY_ENV_VARS=("OPENAI_API_KEY=sk-...")
RY_ADDITIONAL_VOLUMES=("/data/shared:/data:ro")
```

Then just run `roninyolo` from that directory — the project config is picked up automatically.

## License

MIT — see [LICENSE](LICENSE).
