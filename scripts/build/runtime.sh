#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.sh"

BASE_CONDA_VERSION="${BASE_CONDA_VERSION:-$(require_version base_conda)}"
BASE_CONDA_IMAGE="${BASE_CONDA_IMAGE:-jupyter-extended-base-conda:${BASE_CONDA_VERSION}}"
IMAGE_REPO="${IMAGE_REPO:-jupyter-extended}"
TAG="${TAG:-$(require_version runtime)}"
PUSH="${PUSH:-0}"

cd "${REPO_ROOT}"

docker build \
  --build-arg BASE_CONDA_IMAGE="${BASE_CONDA_IMAGE}" \
  -f docker/runtime/Dockerfile \
  -t "${IMAGE_REPO}:${TAG}" \
  -t "${IMAGE_REPO}:latest" \
  .

if [ "${PUSH}" = "1" ]; then
  docker push "${IMAGE_REPO}:${TAG}"
  docker push "${IMAGE_REPO}:latest"
fi

echo "Built ${IMAGE_REPO}:${TAG} (BASE_CONDA_IMAGE=${BASE_CONDA_IMAGE})"
