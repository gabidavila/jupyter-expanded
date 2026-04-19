#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.sh"

IMAGE_REPO="${IMAGE_REPO:-jupyter-extended}"
VERSION_TAG="${VERSION_TAG:-$(require_version runtime)}"
SOURCE_TAG="${SOURCE_TAG:-latest}"
PUSH="${PUSH:-0}"

cd "${REPO_ROOT}"

docker tag "${IMAGE_REPO}:${SOURCE_TAG}" "${IMAGE_REPO}:${VERSION_TAG}"
docker tag "${IMAGE_REPO}:${SOURCE_TAG}" "${IMAGE_REPO}:latest"

if [ "${PUSH}" = "1" ]; then
  docker push "${IMAGE_REPO}:${VERSION_TAG}"
  docker push "${IMAGE_REPO}:latest"
fi

echo "Tagged ${IMAGE_REPO}:${VERSION_TAG} from ${IMAGE_REPO}:${SOURCE_TAG}"
