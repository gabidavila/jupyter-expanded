#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-jupyter-extended:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-jupyter-extended-dev}"
HOST_PORT="${HOST_PORT:-8888}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(pwd)}"

exec docker run --rm -it \
  -p "${HOST_PORT}:8888" \
  -v "${WORKSPACE_DIR}:/workspace" \
  --name "${CONTAINER_NAME}" \
  "${IMAGE}"
