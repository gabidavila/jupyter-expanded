#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-jupyter-extended:latest}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=== Kernel Specs ==="

docker run --rm "${IMAGE}" /bin/bash -lc "/opt/conda/bin/jupyter kernelspec list"

echo "=== Smoke Tests ==="
"${REPO_ROOT}/tests/smoke/test_jupyter.sh" "${IMAGE}"
"${REPO_ROOT}/tests/smoke/test_ruby_kernel.sh" "${IMAGE}"
"${REPO_ROOT}/tests/smoke/test_php_kernel.sh" "${IMAGE}"

echo "All smoke tests passed for ${IMAGE}"
