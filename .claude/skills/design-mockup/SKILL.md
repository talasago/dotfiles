---
description: Issue等がClaude Designのモックアップ（claude.ai/design/p/...のURL）を参照しているとき、DesignSyncツールでデザインの一次情報を取得する。WebFetchは使わない。
when_to_use: デザイン原本を確認して、モックアップに合わせて実装して、claude.ai/designのURLが参照されているとき、design-mockup
---

# design-mockup

Issue等が参照しているデザイン（`claude.ai/design/p/<projectId>/...`）を確認する手順。
**WebFetchではなくDesignSyncツールを使う**（WebFetchではSPAシェルしか取得できない）。

## 手順

1. URLの `/design/p/` 直後のUUIDを projectId として `get_project` に渡し、アクセス可否を確認する
2. `list_files` → `get_file` で該当ファイル（`.dc.html`）の内容を取得する
3. 取得したHTMLのインラインstyle・stateロジックを一次情報として扱い、実際のレイアウト・文言をそこから読み取る

## 取得できない場合（アクセス権がない等）

- 自己判断でレイアウト・見た目・文言を独自に実装して進めない
- 取得できなかった旨をユーザーに伝えて**そこでストップする**
- スクリーンショット共有・自己判断での続行可否といった代替案をこちらから提案しない
