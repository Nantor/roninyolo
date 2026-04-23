# roninyolo profile: claude
# Runs Claude Code (Anthropic CLI) inside a container.
#
# Profile variables use conditional assignment (:=) so that
# user config files always take precedence.

# Base image passed to the Dockerfile's FROM (via --build-arg BASE_IMAGE).
# The default points at the official Claude Code image so `roninyolo build`
# can layer customisations on top of it.
RY_BASE_IMAGE="${RY_BASE_IMAGE:-ghcr.io/anthropics/claude-code:latest}"

# Image tag used by `docker run` (and `docker build -t` when building).
# Defaults to the upstream image so no build step is required.
RY_IMAGE="${RY_IMAGE:-ghcr.io/anthropics/claude-code:latest}"

RY_HOST_CONFIG_DIR="${RY_HOST_CONFIG_DIR:-$HOME/.claude}"
RY_CONTAINER_CONFIG_DIR="${RY_CONTAINER_CONFIG_DIR:-/root/.claude}"

if [[ ${#RY_DEFAULT_CMD[@]} -eq 0 ]]; then
  RY_DEFAULT_CMD=(claude)
fi
