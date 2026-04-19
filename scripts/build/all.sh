#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.sh"

BASE_OS_VERSION="${BASE_OS_VERSION:-$(require_version base_os)}"
BASE_CONDA_VERSION="${BASE_CONDA_VERSION:-$(require_version base_conda)}"
RUNTIME_VERSION="${RUNTIME_VERSION:-$(require_version runtime)}"

BASE_OS_REPO="${BASE_OS_REPO:-jupyter-extended-base-os}"
BASE_CONDA_REPO="${BASE_CONDA_REPO:-jupyter-extended-base-conda}"
RUNTIME_REPO="${RUNTIME_REPO:-jupyter-extended}"
PUSH="${PUSH:-0}"

if [ -z "${BASE_OS_VERSION}" ] || [ -z "${BASE_CONDA_VERSION}" ] || [ -z "${RUNTIME_VERSION}" ]; then
  echo "Missing version values in versions.yaml" >&2
  exit 1
fi

cd "${REPO_ROOT}"

echo "[1/3] Building base-os..."
docker build \
  -f docker/base-os/Dockerfile \
  -t "${BASE_OS_REPO}:${BASE_OS_VERSION}" \
  -t "${BASE_OS_REPO}:stable" \
  .

echo "[2/3] Building base-conda..."
docker build \
  --build-arg BASE_OS_IMAGE="${BASE_OS_REPO}:${BASE_OS_VERSION}" \
  -f docker/base-conda/Dockerfile \
  -t "${BASE_CONDA_REPO}:${BASE_CONDA_VERSION}" \
  -t "${BASE_CONDA_REPO}:stable" \
  .

echo "[3/3] Building runtime..."
docker build \
  --build-arg BASE_CONDA_IMAGE="${BASE_CONDA_REPO}:${BASE_CONDA_VERSION}" \
  -f docker/runtime/Dockerfile \
  -t "${RUNTIME_REPO}:${RUNTIME_VERSION}" \
  -t "${RUNTIME_REPO}:latest" \
  .

if [ "${PUSH}" = "1" ]; then
  docker push "${BASE_OS_REPO}:${BASE_OS_VERSION}"
  docker push "${BASE_OS_REPO}:stable"
  docker push "${BASE_CONDA_REPO}:${BASE_CONDA_VERSION}"
  docker push "${BASE_CONDA_REPO}:stable"
  docker push "${RUNTIME_REPO}:${RUNTIME_VERSION}"
  docker push "${RUNTIME_REPO}:latest"
fi

echo "Built all images:"
echo "  ${BASE_OS_REPO}:${BASE_OS_VERSION}"
echo "  ${BASE_CONDA_REPO}:${BASE_CONDA_VERSION}"
echo "  ${RUNTIME_REPO}:${RUNTIME_VERSION}"
