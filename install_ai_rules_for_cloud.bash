#!/usr/bin/env bash

set -euo pipefail

error() {
  printf 'install_ai_rules_for_cloud.bash: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat >&2 <<'EOF'
使い方: install_ai_rules_for_cloud.bash --target {claude|codex}
EOF
  exit 1
}

SCRIPT_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P
) || error 'スクリプトの配置場所を取得できません。'
readonly SCRIPT_DIR

readonly SOURCE_ROOT=$SCRIPT_DIR/.claude
readonly CLAUDE_ENTRY_FILENAME='CLAUDE.md'
readonly CODEX_ENTRY_FILENAME='AGENTS.md'

target=''
if [ "$#" -eq 2 ] && [ "$1" = '--target' ]; then
  target=$2
else
  usage
fi

case $target in
  claude)
    entry_source=$SCRIPT_DIR/$CLAUDE_ENTRY_FILENAME
    entry_filename=$CLAUDE_ENTRY_FILENAME
    entry_destination_root=${HOME:-}/.claude
    ;;
  codex)
    entry_source=$SCRIPT_DIR/$CODEX_ENTRY_FILENAME
    entry_filename=$CODEX_ENTRY_FILENAME
    entry_destination_root=${HOME:-}/.codex
    ;;
  *) usage ;;
esac

[ -n "${HOME:-}" ] || error 'HOME が設定されていません。'
[ -f "$SCRIPT_DIR/$CLAUDE_ENTRY_FILENAME" ] || error "入力ファイルがありません: $SCRIPT_DIR/$CLAUDE_ENTRY_FILENAME"
[ -f "$SCRIPT_DIR/$CODEX_ENTRY_FILENAME" ] || error "入力ファイルがありません: $SCRIPT_DIR/$CODEX_ENTRY_FILENAME"
[ -d "$SOURCE_ROOT/agents" ] || error "入力ディレクトリがありません: $SOURCE_ROOT/agents"
[ -d "$SOURCE_ROOT/rules" ] || error "入力ディレクトリがありません: $SOURCE_ROOT/rules"
[ -d "$SOURCE_ROOT/skills" ] || error "入力ディレクトリがありません: $SOURCE_ROOT/skills"

copy_shared_assets() {
  local destination_root=$1
  local -a find_exclusions=( ! -name 'settings.local.json' )

  if [ "$target" = codex ]; then
    find_exclusions+=( ! -name 'settings.json' )
  fi

  mkdir -p -- "$destination_root" || error "出力ディレクトリを作成できません: $destination_root"

  (
    cd -- "$SOURCE_ROOT"
    find -P . -mindepth 1 "${find_exclusions[@]}" -print0 |
      xargs -0 -r cp -RL --parents -t "$destination_root"
  )
}

mkdir -p -- "$entry_destination_root" ||
  error "出力ディレクトリを作成できません: $entry_destination_root"

# -L ensures that a source symlink is copied as its contents, not as a link.
cp -L -- "$entry_source" "$entry_destination_root/$entry_filename"
copy_shared_assets "${HOME:-}/.claude"

printf 'AI rules を target=%s としてインストールしました。\n' "$target"
