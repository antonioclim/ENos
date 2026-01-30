# Dockerfile for Project Evaluation Sandbox
# Operating Systems | ASE Bucharest - CSIE
# Provides isolated environment for running student code safely

FROM ubuntu:24.04

LABEL maintainer="Operating Systems Course <os@ase.ro>"
LABEL description="Sandbox environment for automated project evaluation"
LABEL version="1.0"

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Bucharest

# Install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Shell and scripting
    bash \
    dash \
    zsh \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    # Development tools
    git \
    make \
    gcc \
    # Text processing
    gawk \
    mawk \
    sed \
    grep \
    # Utilities
    curl \
    wget \
    jq \
    bc \
    tree \
    file \
    # System tools
    procps \
    htop \
    net-tools \
    iproute2 \
    # Analysis tools
    shellcheck \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for analysis
RUN pip3 install --break-system-packages \
    pylint \
    flake8 \
    pyyaml \
    rich

# Create evaluation user (non-root)
RUN useradd -m -s /bin/bash evaluator \
    && mkdir -p /project /results \
    && chown -R evaluator:evaluator /project /results

# Set resource limits
# Note: These are defaults, can be overridden at runtime
ENV TIMEOUT=60
ENV MAX_MEMORY="512m"
ENV MAX_PIDS=100

# Copy evaluation scripts
COPY --chown=evaluator:evaluator run_auto_eval_EN.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_auto_eval_EN.sh

# Switch to non-root user
USER evaluator
WORKDIR /project

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD bash -c 'echo "ok"' || exit 1

# Default command
CMD ["bash"]

# Usage:
# Build:
#   docker build -t os-eval-sandbox .
#
# Run evaluation:
#   docker run --rm \
#       --memory=512m \
#       --pids-limit=100 \
#       --cpus=1 \
#       --network=none \
#       -v /path/to/project:/project:ro \
#       -v /path/to/results:/results \
#       os-eval-sandbox \
#       /usr/local/bin/run_auto_eval_EN.sh /project -o /results
#
# Interactive debugging:
#   docker run --rm -it \
#       -v /path/to/project:/project \
#       os-eval-sandbox \
#       bash
