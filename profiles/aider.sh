# roninyolo profile: aider
# Runs aider (AI pair programming) inside a container.
#
# Profile variables use conditional assignment (:=) so that
# user config files always take precedence.

RY_IMAGE="${RY_IMAGE:-paulgauthier/aider-full}"
RY_HOST_CONFIG_DIR="${RY_HOST_CONFIG_DIR:-$HOME/.aider}"
RY_CONTAINER_CONFIG_DIR="${RY_CONTAINER_CONFIG_DIR:-/root/.aider}"

if [[ ${#RY_DEFAULT_CMD[@]} -eq 0 ]]; then
  RY_DEFAULT_CMD=(aider)
fi
