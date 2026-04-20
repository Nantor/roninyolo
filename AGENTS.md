# roninyolo - Agent Instructions

## Project Overview

`roninyolo` is a Bash CLI tool that wraps opencode (or other CLI tools) in a container with mounted config and working directory. Main script: `bin/roninyolo`.

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
- `RY_IMAGE` - container image
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
