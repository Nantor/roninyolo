# roninyolo profile: opencode
# Default profile — runs opencode inside a container.
#
# Profile variables use conditional assignment (:=) so that
# user config files always take precedence.

# Base image passed to the Dockerfile's FROM (via --build-arg BASE_IMAGE).
# Override this to build on top of a different distro.
RY_BASE_IMAGE="${RY_BASE_IMAGE:-debian:12-slim}"

# Image tag for the built image (used by `docker run` and `docker build -t`).
RY_IMAGE="${RY_IMAGE:-roninyolo/opencode:local}"

RY_HOST_CONFIG_DIR="${RY_HOST_CONFIG_DIR:-$HOME/.config/opencode}"
RY_CONTAINER_CONFIG_DIR="${RY_CONTAINER_CONFIG_DIR:-/root/.config/opencode}"

if [[ ${#RY_DEFAULT_CMD[@]} -eq 0 ]]; then
  RY_DEFAULT_CMD=(opencode)
fi
