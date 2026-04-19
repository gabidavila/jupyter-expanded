#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

exec jupyter lab \
  --ip=0.0.0.0 \
  --port="${JUPYTER_PORT:-8888}" \
  --no-browser
