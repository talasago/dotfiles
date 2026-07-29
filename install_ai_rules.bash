#!/usr/bin/env bash

set -euo pipefail

readonly PROGRAM_NAME=${BASH_SOURCE[0]##*/}

error() {
  printf '%s: %s\n' "$PROGRAM_NAME" "$*" >&2
  exit 1
}

print_usage() {
  cat <<'EOF'
使い方: install_ai_rules.bash --environment {cloud|local} --target {claude|codex|all}

例:
  install_ai_rules.bash --environment cloud --target claude
  install_ai_rules.bash --environment local --target codex
  install_ai_rules.bash --environment local --target all

environment:
  cloud  管理対象をホームディレクトリへコピーします。
  local  管理対象をホームディレクトリからこのリポジトリへリンクします。

target:
  claude  Claude Code の設定をインストールします。
  codex   Codex の設定と共有 AI rules をインストールします。
  all     Claude Code と Codex の両方をインストールします。
EOF
}

SCRIPT_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P
) || error 'スクリプトの配置場所を取得できません。'
readonly SCRIPT_DIR

readonly SOURCE_ROOT=$SCRIPT_DIR/.claude
readonly CLAUDE_ENTRY_SOURCE=$SCRIPT_DIR/CLAUDE.md
readonly CODEX_ENTRY_SOURCE=$SCRIPT_DIR/AGENTS.md

environment=''
target=''

while [[ $# -gt 0 ]]; do
  case $1 in
    --environment)
      [[ $# -ge 2 ]] || error '--environment の値がありません。'
      environment=$2
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || error '--target の値がありません。'
      target=$2
      shift 2
      ;;
    -h | --help)
      print_usage
      exit 0
      ;;
    *)
      print_usage >&2
      error "不明な引数です: $1"
      ;;
  esac
done

case $environment in
  cloud | local) ;;
  *)
    print_usage >&2
    error '--environment には cloud または local を指定してください。'
    ;;
esac

case $target in
  claude | codex | all) ;;
  *)
    print_usage >&2
    error '--target には claude、codex、all のいずれかを指定してください。'
    ;;
esac

[[ -n ${HOME:-} ]] || error 'HOME が設定されていません。'
case $HOME in
  /*) ;;
  *) error "HOME は絶対パスで指定してください: $HOME" ;;
esac

[[ -f $CLAUDE_ENTRY_SOURCE ]] || error "入力ファイルがありません: $CLAUDE_ENTRY_SOURCE"
[[ -f $CODEX_ENTRY_SOURCE ]] || error "入力ファイルがありません: $CODEX_ENTRY_SOURCE"
[[ -d $SOURCE_ROOT/agents ]] || error "入力ディレクトリがありません: $SOURCE_ROOT/agents"
[[ -d $SOURCE_ROOT/rules ]] || error "入力ディレクトリがありません: $SOURCE_ROOT/rules"
[[ -d $SOURCE_ROOT/skills ]] || error "入力ディレクトリがありません: $SOURCE_ROOT/skills"

sources=()
destinations=()
required_directories=()
shared_asset_find_exclusions=( ! -name 'settings.local.json' )

if [[ $environment = local || $target = codex ]]; then
  shared_asset_find_exclusions+=( ! -name 'settings.json' )
fi

append_install_mapping() {
  sources[${#sources[@]}]=$1
  destinations[${#destinations[@]}]=$2
}

build_install_plan() {
  local relative_path
  local source_path

  case $target in
    claude)
      append_install_mapping "$CLAUDE_ENTRY_SOURCE" "$HOME/.claude/CLAUDE.md"
      required_directories[${#required_directories[@]}]=$HOME/.claude
      ;;
    codex)
      append_install_mapping "$CODEX_ENTRY_SOURCE" "$HOME/.codex/AGENTS.md"
      required_directories[${#required_directories[@]}]=$HOME/.codex
      required_directories[${#required_directories[@]}]=$HOME/.claude
      ;;
    all)
      append_install_mapping "$CLAUDE_ENTRY_SOURCE" "$HOME/.claude/CLAUDE.md"
      append_install_mapping "$CODEX_ENTRY_SOURCE" "$HOME/.codex/AGENTS.md"
      required_directories[${#required_directories[@]}]=$HOME/.claude
      required_directories[${#required_directories[@]}]=$HOME/.codex
      ;;
  esac

  [[ $environment = local ]] || return 0

  while IFS= read -r -d '' relative_path; do
    source_path=$SOURCE_ROOT/${relative_path#./}

    if [[ -d $source_path && ! -L $source_path ]]; then
      required_directories[${#required_directories[@]}]="$HOME/.claude/${relative_path#./}"
    else
      append_install_mapping \
        "$source_path" \
        "$HOME/.claude/${relative_path#./}"
    fi
  done < <(
    cd -- "$SOURCE_ROOT"
    find -P . -mindepth 1 \
      \( -type d -o \
        \( \( -type f -o -type l \) "${shared_asset_find_exclusions[@]}" \) \
      \) -print0
  )
}

copy_install_items() {
  local index
  local destination_parent

  for ((index = 0; index < ${#sources[@]}; index += 1)); do
    destination_parent=$(dirname -- "${destinations[$index]}")
    mkdir -p -- "$destination_parent" ||
      error "出力ディレクトリを作成できません: $destination_parent"
    cp -L -- "${sources[$index]}" "${destinations[$index]}" ||
      error "ファイルをコピーできません: ${destinations[$index]}"
  done

  mkdir -p -- "$HOME/.claude" ||
    error "出力ディレクトリを作成できません: $HOME/.claude"

  (
    cd -- "$SOURCE_ROOT"
    find -P . -mindepth 1 \( -type f -o -type l \) \
      "${shared_asset_find_exclusions[@]}" -print0 |
      xargs -0 -r cp -RL --parents -t "$HOME/.claude"
  ) || error "共有 AI rules をコピーできません: $HOME/.claude"
}

require_jq() {
  command -v jq >/dev/null 2>&1 && return 0

  case $(uname) in
    Darwin)
      error 'jq が必要です。brew install jq を実行してから再試行してください。'
      ;;
    Linux)
      error 'jq が必要です。利用中のパッケージマネージャーで jq をインストールしてから再試行してください（例: sudo apt-get install jq）。'
      ;;
    *)
      error 'jq が必要です。jq をインストールしてから再試行してください。'
      ;;
  esac
}

merge_local_claude_settings() {
  local destination=$HOME/.claude/settings.json
  local temporary_settings

  if [[ ! -e $destination && ! -L $destination ]]; then
    cp -L -- "$SOURCE_ROOT/settings.json" "$destination" ||
      error "Claude Code設定をコピーできません: $destination"
    return 0
  fi

  require_jq
  temporary_settings=$(mktemp "$HOME/.claude/settings.json.tmp.XXXXXX") ||
    error 'Claude Code設定用の一時ファイルを作成できません。'

  jq -s '
    .[0] + (
      .[1]
      | with_entries(
          select(
            .key == "extraKnownMarketplaces" or
            .key == "enabledPlugins" or
            .key == "statusLine" or
            .key == "env"
          )
        )
    )
  ' "$SOURCE_ROOT/settings.json" "$destination" >"$temporary_settings" || {
    rm -f -- "$temporary_settings"
    error "Claude Code設定をマージできません: $destination"
  }

  chmod 600 -- "$temporary_settings" ||
    error "Claude Code設定の権限を変更できません: $temporary_settings"
  mv -- "$temporary_settings" "$destination" ||
    error "Claude Code設定を更新できません: $destination"
}

conflicts=()

preflight_local_install() {
  local index
  local source
  local destination
  local current_link
  local required_directory

  for ((index = 0; index < ${#sources[@]}; index += 1)); do
    source=${sources[$index]}
    destination=${destinations[$index]}

    if [[ -L $destination ]]; then
      current_link=$(readlink "$destination")
      [[ $current_link = "$source" ]] ||
        conflicts[${#conflicts[@]}]=$destination
    elif [[ -e $destination ]]; then
      conflicts[${#conflicts[@]}]=$destination
    fi
  done

  for required_directory in "${required_directories[@]}"; do
    if [[ (-e $required_directory || -L $required_directory) &&
      ! -d $required_directory ]]; then
      conflicts[${#conflicts[@]}]=$required_directory
    fi
  done

  [[ ${#conflicts[@]} -eq 0 ]] || {
    printf '%s: 既存のファイルまたはリンクと競合しています:\n' "$PROGRAM_NAME" >&2
    for destination in "${conflicts[@]}"; do
      printf '  %s\n' "$destination" >&2
    done
    printf '既存データを確認・退避してから再実行してください。\n' >&2
    exit 1
  }
}

link_install_items() {
  local index
  local source
  local destination

  preflight_local_install

  mkdir -p -- "${required_directories[@]}" ||
    error '出力ディレクトリを作成できません。'

  case $target in
    claude | all) merge_local_claude_settings ;;
  esac

  for ((index = 0; index < ${#sources[@]}; index += 1)); do
    source=${sources[$index]}
    destination=${destinations[$index]}

    if [[ -L $destination ]]; then
      continue
    fi

    ln -s -- "$source" "$destination" ||
      error "シンボリックリンクを作成できません: $destination"
  done
}

build_install_plan

case $environment in
  cloud) copy_install_items ;;
  local) link_install_items ;;
esac

printf 'AI rules を environment=%s target=%s としてインストールしました。\n' \
  "$environment" "$target"
