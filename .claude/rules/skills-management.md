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
