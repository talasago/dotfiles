---
paths:
  - "package.json"
  - "pnpm-lock.yaml"
---

# pnpm

`package.json` の `scripts` を追加・変更した際は、pnpmコマンド一覧を管理しているドキュメントがあれば合わせて更新する。

依存関係の共通方針は `.claude/rules/dependency-management.md` に従う。

## 依存パッケージの追加・更新フロー

依存パッケージを追加・更新する際は必ず以下の順で実行する。

1. プロジェクトが使用するNode.js・pnpmの対応範囲を確認する
2. 対応範囲内で採用するバージョンを確認する
3. `package.json`に完全固定バージョン（`^`や`~`なし）で記録する
4. `pnpm install`を実行し、`pnpm-lock.yaml`を更新する
5. `pnpm audit`を実行する
6. 脆弱性が残る場合は、内容と対応要否を確認する
