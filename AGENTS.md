# roninyolo - Agent Instructions

## Project Overview

`roninyolo` is a Bash CLI tool that wraps opencode (or other CLI tools) in a container with mounted config and working directory. Main script: `bin/roninyolo`.

## Language & Portability

**Bash is the intentional, permanent choice for this project.**

- This is a ~200-line glue script that wraps `docker`/`podman` calls. Every platform capable of running Docker/Podman (Linux, macOS, BSD, Windows WSL2) has Bash available.
- **Do not propose rewrites to other languages** (Python, Go, Rust, PowerShell, etc.). Such rewrites add build/install steps and runtime dependencies while providing zero new platform coverage.
- The real portability ceiling is the container runtime, not the shell language. Changing languages does not solve iOS, Termux, or native Windows PowerShell limitations.

**Bash 3.2 compatibility is required.**

macOS ships Bash 3.2 by default. Code must not rely on Bash 4+ features:

- No `${var,,}` / `${var^^}` (case conversion) — use `tr` instead
- No `mapfile` / `readarray` — use while loops
- No associative arrays (`declare -A`)
- No `&>` redirection — use `>file 2>&1`

Use `shellcheck` and test on macOS CI to catch violations.

## Key Commands

```bash
# Run container (default: opencode, or custom CMD)
./bin/roninyolo [CMD ...]

# Build image from RY_DOCKERFILE
./bin/roninyolo build

# Show help
./bin/roninyolo help
```

## Testing

```bash
# Run Bats tests
bats tests/

# ShellCheck static analysis
shellcheck bin/roninyolo
```

## Configuration Model

Config files loaded in precedence order (later overrides earlier):

1. `/etc/roninyolo.conf` - system-wide
2. `$HOME/.config/roninyolo.conf` - per-user
3. `$PWD/.roninyolo.conf` - project-local

All config via shell variables (no env-based config at runtime). Key variables:

- `RY_DOCKER_BIN` - "docker" or "podman"
- `RY_IMAGE` - image tag used by `docker run` and `docker build -t`
- `RY_BASE_IMAGE` - base image for the Dockerfile's `FROM` (passed as `--build-arg BASE_IMAGE` during `roninyolo build`)
- `RY_HOST_CONFIG_DIR` - host config path
- `RY_CONTAINER_CONFIG_DIR` - config path inside container
- `RY_WORKDIR` - working directory inside container
- `RY_DOCKER_USER` - user inside container (empty = current UID:GID, or "root", "opencode", or "UID:GID")
- `RY_ENV_VARS` - array of KEY=VALUE env vars
- `RY_ADDITIONAL_VOLUMES` - array of volume mounts
- `RY_DOCKER_RUN_EXTRA_ARGS` - array of extra docker run args
- `RY_DOCKERFILE` - Dockerfile path for build command
- `RY_BUILD_CONTEXT` - build context for docker build
- `RY_DEFAULT_CMD` - default command array (e.g., `(opencode)`)

## Architecture Notes

- Entry point: `bin/roninyolo` (single script, no subcommands in bin/)
- Config files are sourced (`. "$file"`), so they must be valid Bash
- Script uses `set -euo pipefail` - strict mode
- User defaults to `$(id -u):$(id -g)` to preserve file ownership
- Config mounted `:ro` (read-only) for safety
- Current directory mounted RW at `RY_WORKDIR`

## CI/CD

- GitHub Actions: `.github/workflows/ci.yml`
- ShellCheck excludes: SC1091, SC2034, SC2154 (see `.shellcheckrc`)
- Tests use Bats framework

## Conventions

- All arrays use Bash arrays: `VAR=( "item1" "item2" )`
- All variables quoted: `"$var"`
- No `eval` on user/config input
- Config variables use `RY_` prefix
