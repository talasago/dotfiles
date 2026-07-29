#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P
) || {
  printf 'install_ai_rules_for_cloud.bash: スクリプトの配置場所を取得できません。\n' >&2
  exit 1
}
readonly SCRIPT_DIR

exec "$SCRIPT_DIR/install_ai_rules.bash" --environment cloud "$@"
