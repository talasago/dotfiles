# Codex Remote のルーター

`CLAUDE.md` および `.claude/` の指示を、このリポジトリの作業規約として扱うこと。
 Codex 固有の仕様と矛盾する場合は、Codex で実行可能な範囲に読み替えること。

このファイルは Codex Remote 用の薄いルーターです。詳細なルール、サブエージェント、
スキルの本文は、Claude Code と共有する次のディレクトリに一元化されています。

- 詳細ルール: `~/.claude/rules/` 、`${project_repository_root}/.claude/rules/`
- サブエージェント: `~/.claude/agents/`、、`${project_repository_root}/.claude/agents/`
- スキル: `~/.claude/skills/`、`${project_repository_root}/.claude/skills/`

## 具体的なRule routing

対象ファイルと作業内容に応じて、次のルールだけを読み込んでください。

- `package.json`、`pnpm-lock.yaml`、`package-lock.json`、`yarn.lock`、`Gemfile`、`Gemfile.lock` → `.claude/rules/dependency-management.md`
- `.github/workflows/**` → `.claude/rules/github-actions.md`
- `.claude/skills/**` → `.claude/rules/skills-management.md`

一致するものがなければ、ルールファイル・エージェント・スキルは読みません。
複数一致する場合は、該当するものをすべて読みます。
