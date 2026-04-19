#!/usr/bin/env bash
set -euo pipefail

curl -fsS "http://127.0.0.1:${JUPYTER_PORT:-8888}/lab" > /dev/null
