# roninyolo profile: claude
# Runs Claude Code (Anthropic CLI) inside a container.
#
# Profile variables use conditional assignment (:=) so that
# user config files always take precedence.

RY_IMAGE="${RY_IMAGE:-ghcr.io/anthropics/claude-code:latest}"
RY_HOST_CONFIG_DIR="${RY_HOST_CONFIG_DIR:-$HOME/.claude}"
RY_CONTAINER_CONFIG_DIR="${RY_CONTAINER_CONFIG_DIR:-/root/.claude}"

if [[ ${#RY_DEFAULT_CMD[@]} -eq 0 ]]; then
  RY_DEFAULT_CMD=(claude)
fi
