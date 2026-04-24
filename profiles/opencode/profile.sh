# roninyolo profile: opencode
# Default profile — runs opencode inside a container.
#
# Profile variables use conditional assignment (:=) so that
# user config files always take precedence.

# Image tag for the built image (used by `docker run` and `docker build -t`).
RY_IMAGE="${RY_IMAGE:-roninyolo/opencode:local}"

RY_HOST_CONFIG_DIR="${RY_HOST_CONFIG_DIR:-$HOME/.config/opencode}"
RY_CONTAINER_CONFIG_DIR="${RY_CONTAINER_CONFIG_DIR:-/root/.config/opencode}"

# Point build commands at the Dockerfile co-located with this profile.
# RY_PROFILE_DIR is set by load_profile before this file is sourced.
RY_DOCKERFILE="${RY_DOCKERFILE:-${RY_PROFILE_DIR}/Dockerfile}"
RY_BUILD_CONTEXT="${RY_BUILD_CONTEXT:-${RY_PROFILE_DIR}}"

if [[ ${#RY_DEFAULT_CMD[@]} -eq 0 ]]; then
  RY_DEFAULT_CMD=(opencode)
fi
