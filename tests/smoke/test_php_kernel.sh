#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-jupyter-extended:latest}"

docker run --rm "${IMAGE}" /bin/bash -c "\
  command -v jupyter-php-kernel && \
  jupyter-php-kernel --help >/dev/null 2>&1 && \
  php -i \
"
