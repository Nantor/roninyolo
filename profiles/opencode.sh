# roninyolo profile: opencode
# Default profile — runs opencode inside a container.
#
# Profile variables use conditional assignment (:=) so that
# user config files always take precedence.

RY_IMAGE="${RY_IMAGE:-debian:12-slim}"
RY_HOST_CONFIG_DIR="${RY_HOST_CONFIG_DIR:-$HOME/.config/opencode}"
RY_CONTAINER_CONFIG_DIR="${RY_CONTAINER_CONFIG_DIR:-/root/.config/opencode}"

if [[ ${#RY_DEFAULT_CMD[@]} -eq 0 ]]; then
  RY_DEFAULT_CMD=(opencode)
fi
