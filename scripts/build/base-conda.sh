#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.sh"

BASE_OS_VERSION="${BASE_OS_VERSION:-$(require_version base_os)}"
BASE_OS_IMAGE="${BASE_OS_IMAGE:-jupyter-extended-base-os:${BASE_OS_VERSION}}"
IMAGE_REPO="${IMAGE_REPO:-jupyter-extended-base-conda}"
TAG="${TAG:-$(require_version base_conda)}"
PUSH="${PUSH:-0}"

cd "${REPO_ROOT}"

docker build \
  --build-arg BASE_OS_IMAGE="${BASE_OS_IMAGE}" \
  -f docker/base-conda/Dockerfile \
  -t "${IMAGE_REPO}:${TAG}" \
  -t "${IMAGE_REPO}:stable" \
  .

if [ "${PUSH}" = "1" ]; then
  docker push "${IMAGE_REPO}:${TAG}"
  docker push "${IMAGE_REPO}:stable"
fi

echo "Built ${IMAGE_REPO}:${TAG} (BASE_OS_IMAGE=${BASE_OS_IMAGE})"
