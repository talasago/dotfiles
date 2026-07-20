#!/usr/bin/env bash

set -euo pipefail

error() {
  printf 'install_ai_rules.bash: %s\n' "$*" >&2
  exit 1
}

SCRIPT_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P
) || error 'スクリプトの配置場所を取得できません。'
readonly SCRIPT_DIR

readonly SOURCE_ROOT=$SCRIPT_DIR/.claude
readonly DESTINATION_ROOT=${HOME:-}/.claude

[ -n "${HOME:-}" ] || error 'HOME が設定されていません。'
[ -f "$SCRIPT_DIR/CLAUDE.md" ] || error "入力ファイルがありません: $SCRIPT_DIR/CLAUDE.md"
[ -d "$SOURCE_ROOT/agents" ] || error "入力ディレクトリがありません: $SOURCE_ROOT/agents"
[ -d "$SOURCE_ROOT/rules" ] || error "入力ディレクトリがありません: $SOURCE_ROOT/rules"
[ -d "$SOURCE_ROOT/skills" ] || error "入力ディレクトリがありません: $SOURCE_ROOT/skills"

mkdir -p -- "$DESTINATION_ROOT" || error "出力ディレクトリを作成できません: $DESTINATION_ROOT"

# -L ensures that a source symlink is copied as its contents, not as a link.
cp -L -- "$SCRIPT_DIR/CLAUDE.md" "$DESTINATION_ROOT/CLAUDE.md"

(
  cd -- "$SOURCE_ROOT"
  find -P . -mindepth 1 ! -name 'settings.local.json' -print0 |
    xargs -0 -r cp -RL --parents -t "$DESTINATION_ROOT"
)

printf 'AI rules を %s にコピーしました。\n' "$DESTINATION_ROOT"
