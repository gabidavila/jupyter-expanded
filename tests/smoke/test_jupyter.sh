#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-jupyter-extended:latest}"

docker run --rm "${IMAGE}" /bin/bash -lc "/opt/conda/bin/python3 --version; /opt/conda/bin/jupyter lab --version"
