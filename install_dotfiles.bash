#!/usr/bin/env bash

set -euo pipefail

readonly PROGRAM_NAME=${BASH_SOURCE[0]##*/}

readonly DOTFILES=(
  .tmux.conf
  .vimrc
  .zprofile
  .zshrc
)

error() {
  printf '%s: %s\n' "$PROGRAM_NAME" "$*" >&2
  exit 1
}

SCRIPT_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P
) || error 'スクリプトの配置場所を取得できません。'
readonly SCRIPT_DIR

[[ -n ${HOME:-} ]] || error 'HOME が設定されていません。'

conflicts=()
for name in "${DOTFILES[@]}"; do
  source_path=$SCRIPT_DIR/$name
  destination=$HOME/$name

  [[ -f $source_path ]] || error "入力ファイルがありません: $source_path"

  if [[ -L $destination ]]; then
    [[ $(readlink "$destination") = "$source_path" ]] ||
      conflicts+=("$destination")
  elif [[ -e $destination ]]; then
    conflicts+=("$destination")
  fi
done

if [[ ${#conflicts[@]} -gt 0 ]]; then
  printf '%s: 既存のファイルまたはリンクと競合しています:\n' "$PROGRAM_NAME" >&2
  printf '  %s\n' "${conflicts[@]}" >&2
  printf '既存データを確認・退避してから再実行してください。\n' >&2
  exit 1
fi

for name in "${DOTFILES[@]}"; do
  destination=$HOME/$name
  [[ -L $destination ]] && continue
  ln -s -- "$SCRIPT_DIR/$name" "$destination" ||
    error "シンボリックリンクを作成できません: $destination"
  printf 'リンクを作成しました: %s\n' "$destination"
done
