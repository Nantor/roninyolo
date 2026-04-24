# Configuration Reference

`roninyolo` is configured entirely through shell config files — no environment variables are read at runtime. Config files are valid Bash scripts that set shell variables.

---

## Config File Precedence

Files are loaded in this order; later files override earlier ones:

| Order | Path | Scope |
|-------|------|-------|
| 1 | `/etc/roninyolo.conf` | System-wide (all users) |
| 2 | `$HOME/.config/roninyolo.conf` | Per-user |
| 3 | `$PWD/.roninyolo.conf` | Per-project (current directory) |

Only files that exist and are readable are loaded. Missing files are silently skipped.

---

## Variables Reference

### `RY_DOCKER_BIN`

The container runtime binary to invoke.

| | |
|---|---|
| **Default** | `docker` |
| **Values** | `docker`, `podman`, or any compatible binary in `PATH` |

**Example:**
```bash
RY_DOCKER_BIN="podman"
```

---

### `RY_IMAGE`

The container image to **run** (passed to `docker run`) and to **tag** when building (passed to `docker build -t`). Set this to the name you want the locally built image to carry, or to an existing upstream image when no build step is needed.

| | |
|---|---|
| **Default** | `roninyolo/opencode:local` (opencode profile) |
| **Values** | Any valid image reference (e.g. `myorg/myimage:latest`) |

**Example:**
```bash
RY_IMAGE="ghcr.io/myorg/opencode:latest"
```

---



### `RY_HOST_CONFIG_DIR`

Path on the **host** to the config directory that will be mounted into the container read-only.

| | |
|---|---|
| **Default** | `$HOME/.config/opencode` |
| **Values** | Any absolute path on the host |

**Example:**
```bash
RY_HOST_CONFIG_DIR="$HOME/.config/myapp"
```

---

### `RY_CONTAINER_CONFIG_DIR`

Path **inside the container** where `RY_HOST_CONFIG_DIR` is mounted. Mounted read-only (`:ro`).

| | |
|---|---|
| **Default** | `/root/.config/opencode` |
| **Values** | Any absolute path inside the container |

**Example:**
```bash
RY_CONTAINER_CONFIG_DIR="/home/opencode/.config/opencode"
```

---

### `RY_WORKDIR`

Working directory **inside the container**. The host's current directory (`$PWD`) is mounted here read-write.

| | |
|---|---|
| **Default** | `/work` |
| **Values** | Any absolute path inside the container |

**Example:**
```bash
RY_WORKDIR="/workspace"
```

---

### `RY_DOCKER_USER`

User identity to run as inside the container.

| | |
|---|---|
| **Default** | *(empty — uses current host `uid:gid`)* |
| **Values** | `""` (current uid:gid), `"root"`, `"opencode"`, or `"UID:GID"` |

When empty, `roninyolo` passes `-u $(id -u):$(id -g)` so files written into `$PWD` are owned by your host user. Set to `"root"` if the image requires root access, or to a named user that exists inside the image.

**Examples:**
```bash
# Run as root
RY_DOCKER_USER="root"

# Run as a named user defined in the image
RY_DOCKER_USER="opencode"

# Explicit numeric mapping
RY_DOCKER_USER="1001:1001"
```

---

### `RY_ENV_VARS`

Array of `KEY=VALUE` strings passed as environment variables into the container via `-e`.

| | |
|---|---|
| **Default** | `()` (empty array) |
| **Values** | Bash array of `KEY=VALUE` strings |

**Example:**
```bash
RY_ENV_VARS=(
  "OPENAI_API_KEY=sk-..."
  "ANTHROPIC_API_KEY=sk-ant-..."
  "DEBUG=1"
)
```

---

### `RY_ADDITIONAL_VOLUMES`

Array of extra volume mount strings passed to `docker run` via `-v`. Each entry uses Docker's standard `host:container[:options]` syntax.

| | |
|---|---|
| **Default** | `()` (empty array) |
| **Values** | Bash array of volume mount strings |

**Example:**
```bash
RY_ADDITIONAL_VOLUMES=(
  "/data/shared:/data:ro"
  "$HOME/.ssh:/root/.ssh:ro"
)
```

---

### `RY_DOCKER_RUN_EXTRA_ARGS`

Array of extra arguments appended to the `docker run` invocation verbatim. Use this for flags not covered by other config variables.

| | |
|---|---|
| **Default** | `()` (empty array) |
| **Values** | Bash array of `docker run` flag strings |

**Example:**
```bash
RY_DOCKER_RUN_EXTRA_ARGS=(
  "--network=host"
  "--memory=4g"
  "--cpus=2"
)
```

---

### `RY_DOCKERFILE`

Path to the Dockerfile used by `roninyolo build`. Must be set before running the `build` subcommand. The Dockerfile should declare `ARG BASE_IMAGE` so that `RY_BASE_IMAGE` is honoured.

| | |
|---|---|
| **Default** | `""` (empty — build will error if not set) |
| **Values** | Relative or absolute path to a Dockerfile |

**Example:**
```bash
# Override only if you want a custom Dockerfile instead of the profile's default.
# Profiles that ship a Dockerfile (e.g. opencode) set this automatically.
RY_DOCKERFILE="profiles/opencode/Dockerfile"
```

---

### `RY_BUILD_CONTEXT`

Build context directory passed to `docker build`. Typically the repo root.

| | |
|---|---|
| **Default** | `.` (current directory) |
| **Values** | Any path accessible to the Docker daemon |

**Example:**
```bash
RY_BUILD_CONTEXT="."
```

---

### `RY_DEFAULT_CMD`

Default command array executed inside the container when `roninyolo` is run with no arguments (or with `run` and no further arguments).

| | |
|---|---|
| **Default** | `(opencode)` |
| **Values** | Bash array (command + arguments) |

**Examples:**
```bash
# Use aider instead of opencode
RY_DEFAULT_CMD=(aider)

# Pass flags to the default command
RY_DEFAULT_CMD=(opencode --no-telemetry)

# Drop into a shell for debugging
RY_DEFAULT_CMD=(bash)
```

---

## Full Example Config File

```bash
# $PWD/.roninyolo.conf — project-local overrides

RY_DOCKER_BIN="podman"

# Image to run (and the tag applied when building)
RY_IMAGE="ghcr.io/myorg/opencode:latest"



RY_HOST_CONFIG_DIR="$HOME/.config/opencode"
RY_CONTAINER_CONFIG_DIR="/home/opencode/.config/opencode"
RY_WORKDIR="/workspace"

RY_DOCKER_USER="opencode"

RY_ENV_VARS=(
  "ANTHROPIC_API_KEY=sk-ant-..."
)

RY_ADDITIONAL_VOLUMES=(
  "$HOME/.ssh:/home/opencode/.ssh:ro"
)

RY_DOCKER_RUN_EXTRA_ARGS=(
  "--network=host"
)

RY_DOCKERFILE="profiles/opencode/Dockerfile"
RY_BUILD_CONTEXT="profiles/opencode"

RY_DEFAULT_CMD=(opencode)
```
