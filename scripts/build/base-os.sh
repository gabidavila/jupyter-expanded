#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.sh"

IMAGE_REPO="${IMAGE_REPO:-jupyter-extended-base-os}"
TAG="${TAG:-$(require_version base_os)}"
PUSH="${PUSH:-0}"

cd "${REPO_ROOT}"

docker build \
  -f docker/base-os/Dockerfile \
  -t "${IMAGE_REPO}:${TAG}" \
  -t "${IMAGE_REPO}:stable" \
  .

if [ "${PUSH}" = "1" ]; then
  docker push "${IMAGE_REPO}:${TAG}"
  docker push "${IMAGE_REPO}:stable"
fi

echo "Built ${IMAGE_REPO}:${TAG}"
