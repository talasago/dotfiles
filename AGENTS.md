# Codex の作業規約

着手時に、存在する `~/.claude/CLAUDE.md` と作業リポジトリの `CLAUDE.md` をその順で読み、作業規約として扱う。同じファイルへのリンクなら一度読む。
Claude Code 固有の操作は、Codex で利用できる機能と許可の範囲で読み替える。
スキルは `.agents/skills/` に公開している。Codex からは `$スキル名` で呼び出せる。

## 具体的なRule routing

対象ファイルと作業内容に応じて、該当するルールを読む。各ルールは作業リポジトリの `.claude/rules/` を優先し、そこに無ければ `~/.claude/rules/` を参照する。

- `package.json`、`pnpm-lock.yaml`、`package-lock.json`、`yarn.lock`、`Gemfile`、`Gemfile.lock` の変更、またはパッケージマネージャーによるライブラリの追加・更新 → `.claude/rules/dependency-management.md`
- `.github/workflows/**` → `.claude/rules/github-actions.md`
- `.claude/skills/**` → `.claude/rules/skills-management.md`
- `**/router.tsx`、`**/router.ts`、`**/routes.tsx`、`**/routes.ts` → `.claude/rules/react-router.md`

## GitHub の参照操作

どのリポジトリでも、PR・Issue・リポジトリ・コミット・リリース・Actions の閲覧、一覧取得、検索など、GitHub の参照操作には `~/.codex/bin/gh-api-get '<REST API のパス>'` を使う。ラッパーは単独で呼び出し、出力の抽出や整形は取得後に行う。
