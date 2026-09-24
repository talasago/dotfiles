#!/usr/bin/env bash
# テストファイル(*.test.ts等・*_spec.rb等)をWrite/Editする前に、
# write-testスキルと対応するフレームワークスキル（write-vitest/write-rspec）が
# 会話内で呼ばれていることを強制するPreToolUseフック。
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

framework_skill=''
if printf '%s' "$file_path" | grep -qE '\.(test|spec)\.(ts|tsx|js|jsx)$'; then
  framework_skill='write-vitest'
elif printf '%s' "$file_path" | grep -qE '(_spec|_test)\.rb$'; then
  framework_skill='write-rspec'
else
  exit 0
fi

if [[ -n $transcript && -f $transcript ]] \
  && grep -q '"skill":"write-test"' "$transcript" \
  && grep -q "\"skill\":\"$framework_skill\"" "$transcript"; then
  exit 0
fi

reason="テストファイルを編集する前に、write-testスキルと${framework_skill}スキルを呼び出してください。"
jq -n --arg reason "$reason" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
