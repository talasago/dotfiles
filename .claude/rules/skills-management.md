---
paths:
  - ".claude/skills/**"
---

# スキルファイルの管理

スキルは `.claude/skills/` ディレクトリに配置する（Claude Code 独自拡張 frontmatter が確実に有効になる）。

スキルを作成する際は、Claude Code の frontmatter 仕様（https://code.claude.com/docs/en/skills）を必ず調べ、指定すべきフィールドを検討してから記述する。

スキルファイルには必ず `description` frontmatter を記述する。

```yaml
---
description: スキルの説明（いつ使うかが分かる内容にする）
---
```

## テストフレームワーク用スキル（write-*）を新規作成する場合

`.claude/hooks/check-test-skill.sh` はテストファイルの拡張子・命名パターンから対応するフレームワークスキル名を決め打ちで判定している。新しいテストフレームワーク用のスキル（`write-pytest`等）を追加する場合、このスクリプトの判定分岐にも対応パターンを追加する。

## 一次情報がある場合の記述方法

参照可能な一次情報（他リポジトリのルールドキュメント、READMEなど）が既にある場合、その内容をSKILL.md本文へ要約・転記しない。一次情報のパス・URLを示し、それを読んで判断するようSKILL.md側から指示するに留める。

転記すると一次情報の更新にSKILL.mdが追従できず内容が古くなる。また、一次情報を読ませず要約だけを当てにする動きを助長しかねない。
