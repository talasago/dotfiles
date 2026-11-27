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
  codex   Codex の指示と共有スキルをインストールします。
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
# git-workflow.md は Claude Code on the web 専用。cloud では読ませる必要があるため、local の user 設定にだけ除外を入れる。
readonly LOCAL_ONLY_CLAUDE_SETTINGS='{"claudeMdExcludes":["**/.claude/rules/git-workflow.md"]}'

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

readonly CODEX_DIRECTORY=${CODEX_HOME:-$HOME/.codex}
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

  append_install_mapping "$CLAUDE_ENTRY_SOURCE" "$HOME/.claude/CLAUDE.md"
  required_directories+=("$HOME/.claude")
  case $target in
    codex | all)
      append_install_mapping "$CODEX_ENTRY_SOURCE" "$CODEX_DIRECTORY/AGENTS.md"
      required_directories+=("$CODEX_DIRECTORY")
      ;;
  esac

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

append_codex_skill_mappings() {
  [[ $target != claude ]] || return 0

  local skill
  local skill_name
  local link_source
  required_directories+=("$HOME/.agents" "$HOME/.agents/skills")

  for skill in "$SOURCE_ROOT"/skills/*; do
    [[ -f $skill/SKILL.md ]] || continue
    skill_name=${skill##*/}
    link_source=$skill
    if [[ $environment = cloud ]]; then
      link_source=$HOME/.claude/skills/$skill_name
    fi
    append_install_mapping "$link_source" "$HOME/.agents/skills/$skill_name"
  done
}

copy_install_items() {
  local index
  for ((index = 0; index < first_link_index; index += 1)); do
    cp -RL -- "${sources[$index]}" "${destinations[$index]}" ||
      error "ファイルをコピーできません: ${destinations[$index]}"
  done
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
  local existing_settings=$destination
  local temporary_settings

  require_jq
  [[ -e $destination || -L $destination ]] || existing_settings=/dev/null
  temporary_settings=$(mktemp "$HOME/.claude/settings.json.tmp.XXXXXX") ||
    error 'Claude Code設定用の一時ファイルを作成できません。'

  # permissionsは端末で「今後も許可」したallowルール等が溜まるため、丸ごと置き換えず
  # 共通設定のキー（defaultMode等）だけを上書きする。
  jq -s --argjson local_only "$LOCAL_ONLY_CLAUDE_SETTINGS" '
    .[0] as $shared
    | (.[1] // {}) as $existing
    | $shared + (
      $existing
      | with_entries(
          select(
            .key == "extraKnownMarketplaces" or
            .key == "enabledPlugins" or
            .key == "statusLine" or
            .key == "env" or
            .key == "model" or
            .key == "modelSettings" or
            .key == "voice" or
            .key == "voiceEnabled"
          )
        )
    ) + (
      if $existing.permissions or $shared.permissions then
        {permissions: (($existing.permissions // {}) + ($shared.permissions // {}))}
      else
        {}
      end
    ) + $local_only
  ' "$SOURCE_ROOT/settings.json" "$existing_settings" >"$temporary_settings" || {
    rm -f -- "$temporary_settings"
    error "Claude Code設定をマージできません: $destination"
  }

  chmod 600 "$temporary_settings" ||
    error "Claude Code設定の権限を変更できません: $temporary_settings"
  mv -- "$temporary_settings" "$destination" ||
    error "Claude Code設定を更新できません: $destination"
}

conflicts=()

preflight_install() {
  local index
  local source
  local destination
  local current_link
  local required_directory

  for ((index = first_link_index; index < ${#sources[@]}; index += 1)); do
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

  for ((index = first_link_index; index < ${#sources[@]}; index += 1)); do
    source=${sources[$index]}
    destination=${destinations[$index]}

    if [[ -L $destination ]]; then
      continue
    fi

    ln -sn -- "$source" "$destination" ||
      error "シンボリックリンクを作成できません: $destination"
  done
}

build_install_plan
first_link_index=0
if [[ $environment = cloud ]]; then
  first_link_index=${#sources[@]}
fi
readonly first_link_index
append_codex_skill_mappings
preflight_install
mkdir -p -- "${required_directories[@]}" ||
  error '出力ディレクトリを作成できません。'

case $environment in
  cloud) copy_install_items ;;
  local)
    case $target in
      claude | all) merge_local_claude_settings ;;
    esac
    ;;
esac
link_install_items

printf 'AI rules を environment=%s target=%s としてインストールしました。\n' \
  "$environment" "$target"
