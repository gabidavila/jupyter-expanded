#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-jupyter-extended:latest}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

"${REPO_ROOT}/tests/smoke/test_jupyter.sh" "${IMAGE}"
"${REPO_ROOT}/tests/smoke/test_php_kernel.sh" "${IMAGE}"
"${REPO_ROOT}/tests/smoke/test_ruby_kernel.sh" "${IMAGE}"
docker run --rm "${IMAGE}" /bin/bash -lc "/opt/conda/bin/jupyter kernelspec list | grep -E 'php|ruby3|python3|xcpp17'"

echo "Smoke tests passed for ${IMAGE}"
