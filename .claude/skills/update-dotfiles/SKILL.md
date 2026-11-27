---
name: update-dotfiles
description: CLAUDE.md・ルール・スキル等の新設や変更が必要になったとき、その内容がこのプロジェクト固有かグローバル（全プロジェクト共通）かを判断し、グローバルなら talasago/dotfiles にPRを送る。
---

# update-dotfiles

`/root/.claude/`（グローバルCLAUDE.md・rules・skills等）はコンテナ起動時に `talasago/dotfiles`
リポジトリから生成される使い捨て領域であり、このセッション内で直接編集しても永続化されない。
グローバル向けの変更が必要な場合は、必ず `talasago/dotfiles` にPRを送る。

## 手順

1. 変更したい内容が、このプロジェクト固有かグローバル（全プロジェクト共通）かを判断する
   - プロジェクト固有 → 通常どおりこのプロジェクトの `CLAUDE.md` / `.claude/rules/` / `.claude/skills/` に追記する（このスキルの対象外）
   - グローバル共通 → 以降の手順に進む
2. `add_repo` ツールで `talasago/dotfiles` をセッションに追加し、クローンする
3. クローンしたリポジトリ内で `main` から新規ブランチを作成する
4. 対応するファイル（`CLAUDE.md` / `.claude/rules/` / `.claude/skills/` 等）を変更する
5. コミット・push・PR作成（PRテンプレートの有無を先に確認する）

## 注意点

- グローバル変更とこのプロジェクトの変更が同時に必要な場合でも、コミット・PRは両リポジトリで分ける
- `talasago/dotfiles` では `git worktree` を使わない。既存のチェックアウトで直接作業する
- `talasago/dotfiles` の内容を直接 `/root/.claude/` にコピーしても、次回コンテナ起動までは反映されるがそれ以降は失われるため、必ずPRまで実施する
- `talasago/dotfiles` 側のコミットメッセージ・PR本文には、変更のきっかけとなった特定プロジェクトのリポジトリ名・Issue番号・PR番号を書かない。dotfilesは全プロジェクト共通の設定を管理するリポジトリであり、特定プロジェクトの文脈に依存させない。
- `talasago/dotfiles` に書く `CLAUDE.md`・ルール・スキルの本文にも、特定プロジェクト固有の情報（リポジトリ名・ディレクトリ構成・ドメイン用語・固有のコマンドや設定値等）を書かない。具体例が必要な場合は、どのプロジェクトにも当てはまる一般的な例に置き換える。
