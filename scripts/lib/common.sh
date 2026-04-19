#!/usr/bin/env bash
set -euo pipefail

export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSIONS_FILE="${REPO_ROOT}/versions.yaml"

version_value() {
  local key="$1"
  awk -F': *' -v key="$key" '$1==key {gsub(/"/,"",$2); print $2}' "${VERSIONS_FILE}"
}

require_version() {
  local key="$1"
  local value
  value="$(version_value "${key}")"
  if [ -z "${value}" ]; then
    echo "Missing version key '${key}' in ${VERSIONS_FILE}" >&2
    exit 1
  fi
  printf '%s' "${value}"
}
