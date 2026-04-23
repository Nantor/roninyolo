ARG BASE_IMAGE=debian:12-slim
FROM ${BASE_IMAGE}

# Basic dependencies for the installer + shell
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      bash \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user "opencode" with uid 1000 for better file permissions
RUN useradd -m -u 1000 opencode

USER opencode
WORKDIR /work

# Install opencode CLI (terminal) for Debian/Ubuntu
RUN curl -fsSL https://opencode.ai/install | bash

# Default command can be overridden by the roninyolo script;
# keep it minimal here.
ENTRYPOINT ["/bin/bash"]
