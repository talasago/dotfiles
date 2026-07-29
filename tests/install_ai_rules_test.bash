#!/usr/bin/env bash

set -euo pipefail

TEST_DIR=$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P
)
readonly TEST_DIR
readonly REPOSITORY_ROOT=$(dirname -- "$TEST_DIR")
readonly INSTALLER=$REPOSITORY_ROOT/install_ai_rules.bash
readonly CLOUD_INSTALLER=$REPOSITORY_ROOT/install_ai_rules_for_cloud.bash
readonly TEST_WORK_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/install-ai-rules-test.XXXXXX")

trap 'rm -rf -- "$TEST_WORK_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_symlink_to() {
  local expected_source=$1
  local destination=$2

  [[ -L $destination ]] || fail "シンボリックリンクではありません: $destination"
  [[ $(readlink "$destination") = "$expected_source" ]] ||
    fail "リンク元が一致しません: $destination"
}

assert_regular_file() {
  local path=$1

  [[ -f $path ]] || fail "ファイルがありません: $path"
  [[ ! -L $path ]] || fail "通常ファイルではありません: $path"
}

assert_absent() {
  local path=$1

  [[ ! -e $path ]] || fail "存在しないはずのパスがあります: $path"
  [[ ! -L $path ]] || fail "存在しないはずのリンクがあります: $path"
}

new_home() {
  mktemp -d "$TEST_WORK_ROOT/home.XXXXXX"
}

test_local_all_installs_claude_and_codex_links() {
  local test_home
  test_home=$(new_home)
  mkdir -p -- "$test_home/.claude/skills/local-only"
  printf 'local only\n' >"$test_home/.claude/skills/local-only/SKILL.md"

  HOME=$test_home "$INSTALLER" --environment local --target all >/dev/null

  assert_symlink_to "$REPOSITORY_ROOT/CLAUDE.md" "$test_home/.claude/CLAUDE.md"
  assert_symlink_to "$REPOSITORY_ROOT/AGENTS.md" "$test_home/.codex/AGENTS.md"
  assert_symlink_to \
    "$REPOSITORY_ROOT/.claude/agents/research.md" \
    "$test_home/.claude/agents/research.md"
  assert_regular_file "$test_home/.claude/skills/local-only/SKILL.md"
  assert_regular_file "$test_home/.claude/settings.json"
  cmp -s "$REPOSITORY_ROOT/.claude/settings.json" "$test_home/.claude/settings.json" ||
    fail '共通のClaude Code設定がコピーされていません。'
  assert_absent "$test_home/.claude/settings.local.json"
}

test_local_codex_does_not_install_claude_settings() {
  local test_home
  test_home=$(new_home)

  HOME=$test_home "$INSTALLER" --environment local --target codex >/dev/null

  assert_symlink_to "$REPOSITORY_ROOT/AGENTS.md" "$test_home/.codex/AGENTS.md"
  assert_symlink_to \
    "$REPOSITORY_ROOT/.claude/skills/write-test/SKILL.md" \
    "$test_home/.claude/skills/write-test/SKILL.md"
  assert_absent "$test_home/.claude/CLAUDE.md"
  assert_absent "$test_home/.claude/settings.json"
  assert_absent "$test_home/.claude/settings.local.json"
}

test_local_claude_preserves_local_settings() {
  local test_home
  test_home=$(new_home)
  mkdir -p -- "$test_home/.claude"
  printf '%s\n' \
    '{"model":"opus","statusLine":{"type":"command","command":"~/.claude/local-statusline.js"},"extraKnownMarketplaces":{"local":{"source":{"source":"github","repo":"example/local"}}},"enabledPlugins":{"local@example":true},"env":{"LOCAL_TOKEN":"secret"},"untrackedSetting":true}' \
    >"$test_home/.claude/settings.json"

  PATH="$REPOSITORY_ROOT/tests/fixtures/bin:$PATH" \
    HOME=$test_home \
    "$INSTALLER" --environment local --target claude >/dev/null

  assert_symlink_to "$REPOSITORY_ROOT/CLAUDE.md" "$test_home/.claude/CLAUDE.md"
  assert_regular_file "$test_home/.claude/settings.json"
  node -e '
    const fs = require("fs");
    const settings = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    if (settings.model !== "sonnet") process.exit(1);
    if (settings.language !== "japanese") process.exit(1);
    if (settings.statusLine.command !== "~/.claude/local-statusline.js") process.exit(1);
    if (settings.enabledPlugins["local@example"] !== true) process.exit(1);
    if (settings.env.LOCAL_TOKEN !== "secret") process.exit(1);
    if (settings.extraKnownMarketplaces.local.source.repo !== "example/local") process.exit(1);
    if ("untrackedSetting" in settings) process.exit(1);
  ' "$test_home/.claude/settings.json" ||
    fail '共通設定と端末固有設定が正しくマージされていません。'
  assert_absent "$test_home/.codex/AGENTS.md"
}

test_local_reinstall_is_idempotent() {
  local test_home
  test_home=$(new_home)
  HOME=$test_home "$INSTALLER" --environment local --target all >/dev/null

  HOME=$test_home "$INSTALLER" --environment local --target all >/dev/null

  assert_symlink_to "$REPOSITORY_ROOT/CLAUDE.md" "$test_home/.claude/CLAUDE.md"
  assert_symlink_to "$REPOSITORY_ROOT/AGENTS.md" "$test_home/.codex/AGENTS.md"
}

test_local_collision_does_not_partially_install() {
  local test_home
  local command_output
  test_home=$(new_home)
  mkdir -p -- "$test_home/.claude"
  printf 'local instructions\n' >"$test_home/.claude/CLAUDE.md"

  command_output=$(
    HOME=$test_home "$INSTALLER" --environment local --target all 2>&1
  ) && fail '競合があるインストールが成功しました。'

  case $command_output in
    *"$test_home/.claude/CLAUDE.md"*) ;;
    *) fail '競合したパスがエラーに表示されていません。' ;;
  esac
  assert_regular_file "$test_home/.claude/CLAUDE.md"
  assert_absent "$test_home/.codex/AGENTS.md"
}

test_local_wrong_link_does_not_partially_install() {
  local test_home
  local command_output
  test_home=$(new_home)
  mkdir -p -- "$test_home/.codex"
  ln -s -- "$REPOSITORY_ROOT/CLAUDE.md" "$test_home/.codex/AGENTS.md"

  command_output=$(
    HOME=$test_home "$INSTALLER" --environment local --target all 2>&1
  ) && fail '別のリンクと競合するインストールが成功しました。'

  case $command_output in
    *"$test_home/.codex/AGENTS.md"*) ;;
    *) fail '競合したリンクがエラーに表示されていません。' ;;
  esac
  assert_absent "$test_home/.claude/CLAUDE.md"
  assert_symlink_to "$REPOSITORY_ROOT/CLAUDE.md" "$test_home/.codex/AGENTS.md"
}

test_local_parent_collision_does_not_partially_install() {
  local test_home
  local command_output
  test_home=$(new_home)
  mkdir -p -- "$test_home/.claude"
  printf 'not a directory\n' >"$test_home/.claude/skills"

  command_output=$(
    HOME=$test_home "$INSTALLER" --environment local --target all 2>&1
  ) && fail '親パスと競合するインストールが成功しました。'

  case $command_output in
    *"$test_home/.claude/skills"*) ;;
    *) fail '競合した親パスがエラーに表示されていません。' ;;
  esac
  assert_absent "$test_home/.claude/CLAUDE.md"
  assert_absent "$test_home/.codex/AGENTS.md"
}

test_cloud_all_copies_regular_files() {
  local test_home
  test_home=$(new_home)

  HOME=$test_home "$INSTALLER" --environment cloud --target all >/dev/null
  printf 'stale\n' >"$test_home/.claude/CLAUDE.md"
  HOME=$test_home "$INSTALLER" --environment cloud --target all >/dev/null

  assert_regular_file "$test_home/.claude/CLAUDE.md"
  cmp -s "$REPOSITORY_ROOT/CLAUDE.md" "$test_home/.claude/CLAUDE.md" ||
    fail 'cloud の再実行でコピー内容が更新されていません。'
  assert_regular_file "$test_home/.codex/AGENTS.md"
  assert_regular_file "$test_home/.claude/settings.json"
  assert_regular_file "$test_home/.claude/rules/github-actions.md"
  assert_absent "$test_home/.claude/settings.local.json"
}

test_cloud_compatibility_wrapper_preserves_codex_behavior() {
  local test_home
  test_home=$(new_home)

  HOME=$test_home "$CLOUD_INSTALLER" --target codex >/dev/null

  assert_regular_file "$test_home/.codex/AGENTS.md"
  assert_regular_file "$test_home/.claude/agents/research.md"
  assert_absent "$test_home/.claude/CLAUDE.md"
  assert_absent "$test_home/.claude/settings.json"
  assert_absent "$test_home/.claude/settings.local.json"
}

test_help_describes_local_all_command() {
  local command_output

  command_output=$("$INSTALLER" --help)

  case $command_output in
    *'--environment local --target all'*) ;;
    *) fail 'help に物理ローカル向け実行例がありません。' ;;
  esac
}

test_error_uses_invoked_program_name() {
  local alias_path=$TEST_WORK_ROOT/custom-installer
  local command_output
  ln -s -- "$INSTALLER" "$alias_path"

  command_output=$("$alias_path" --unknown 2>&1) &&
    fail '不明な引数を指定したインストーラーが成功しました。'

  case $command_output in
    *'custom-installer: 不明な引数です: --unknown'*) ;;
    *) fail 'エラーに実行時のプログラム名が使われていません。' ;;
  esac
}

test_local_all_installs_claude_and_codex_links
test_local_codex_does_not_install_claude_settings
test_local_claude_preserves_local_settings
test_local_reinstall_is_idempotent
test_local_collision_does_not_partially_install
test_local_wrong_link_does_not_partially_install
test_local_parent_collision_does_not_partially_install
test_cloud_all_copies_regular_files
test_cloud_compatibility_wrapper_preserves_codex_behavior
test_help_describes_local_all_command
test_error_uses_invoked_program_name

printf 'PASS: install_ai_rules の全テストが成功しました。\n'
