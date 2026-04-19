#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-jupyter-extended:latest}"

docker run --rm "${IMAGE}" /bin/bash -lc "iruby --version >/dev/null 2>&1; /opt/conda/bin/jupyter kernelspec list | grep -E 'ruby3'"
