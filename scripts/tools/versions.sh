#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/common.sh"

printf 'runtime=%s\n' "$(require_version runtime)"
printf 'base_os=%s\n' "$(require_version base_os)"
printf 'base_conda=%s\n' "$(require_version base_conda)"
printf 'python=%s\n' "$(require_version python)"
printf 'jupyterlab=%s\n' "$(require_version jupyterlab)"
