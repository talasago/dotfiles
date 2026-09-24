#!/usr/bin/env bash
# テストファイルをWrite/Editする前に、write-testスキルが会話内で
# 呼ばれていることを強制するPreToolUseフック。
#
# テストファイルの判定は拡張子ではなくファイル名中の単語（test/spec、区切り文字
# で区切られたもの）で行う。特定の言語・フレームワークに決め打ちしないことで、
# 新しいテストフレームワーク用スキルが増えてもこのスクリプトの更新が不要になる。
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

file_name=$(basename -- "$file_path" 2>/dev/null || true)
if ! printf '%s' "$file_name" | grep -qiE '(^|[._-])(tests?|specs?)([._-]|$)'; then
  exit 0
fi

if [[ -n $transcript && -f $transcript ]] \
  && grep -q '"skill":"write-test"' "$transcript"; then
  exit 0
fi

jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "テストファイルを編集する前に、write-testスキルを呼び出してください。"}}'
