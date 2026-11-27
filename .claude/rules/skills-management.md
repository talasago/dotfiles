---
paths:
  - ".claude/skills/**"
---

# スキルファイルの管理

スキルの原本は `.claude/skills/<スキル名>/SKILL.md` に置く。frontmatter には [Agent Skills 仕様](https://agentskills.io/specification) のフィールドだけを使い、ディレクトリ名と同じ `name` と、用途・起動条件を示す `description` を必ず記述する。

```yaml
---
name: skill-name
description: スキルの説明（いつ使うかが分かる内容にする）
---
```

## 一次情報がある場合の記述方法

参照可能な一次情報（他リポジトリのルールドキュメント、READMEなど）が既にある場合、その内容をSKILL.md本文へ要約・転記しない。一次情報のパス・URLを示し、それを読んで判断するようSKILL.md側から指示するに留める。

転記すると一次情報の更新にSKILL.mdが追従できず内容が古くなる。また、一次情報を読ませず要約だけを当てにする動きを助長しかねない。
