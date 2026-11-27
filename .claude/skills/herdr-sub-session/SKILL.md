---
name: herdr-sub-session
description: herdrの別タブにClaudeのサブセッションを立ててタスクを任せ、結果を回収する。サブセッションは許可ダイアログを出さない設定で動かし、許可が必要な操作はメインセッションが引き取る。
---

# herdr-sub-session

`$0` をサブセッション名（herdrのagent名・タブ名・worktree名を兼ねる。`[a-z][a-z0-9_-]{0,31}`）、`$1` を役割、残りを指示として扱う。

herdrのコマンド構文は `herdr --skill` と各サブコマンドの `--help` を一次情報とする。

## 1. 前提確認

`test "${HERDR_ENV:-}" = 1` が失敗したら、herdr外であることを伝えて止める。

## 2. model / effort を決める

| 役割 | model | effort |
|---|---|---|
| investigate（調査・定型作業） | sonnet | low|
| implement（実装） | opus | medium |
| review（レビュー・難しいデバッグ） | opus | high |

## 3. 作業ディレクトリを用意する

implement はメインの現在のHEADからworktreeを切る。investigate・review はメインと同じディレクトリでよい。

```bash
git worktree add -b <name> "$(git rev-parse --show-toplevel)/../$(basename "$(git rev-parse --show-toplevel)")-worktrees/<name>" HEAD
```

worktreeはリポジトリの外（兄弟ディレクトリ）に置く。リポジトリ内に置くと、`.gitignore` されていない場合にメイン側の `git status` を汚す。

## 4. タブを作ってClaudeを起動する

結果ファイルの置き場所として、メインのscratchpad配下などリポジトリ外のディレクトリを決めておく。

```bash
herdr tab create --label <name> --cwd <作業ディレクトリ> --no-focus
# → .result.root_pane.pane_id
herdr agent start <name> --kind claude --pane <pane_id> -- \
  --model <model> --effort <effort> -n <name> \
  --permission-mode dontAsk --allowedTools "Edit Write" --add-dir <結果ディレクトリ>
```

- `dontAsk` は、事前許可されていない操作を許可ダイアログを出さずに自動拒否する。
- 起動時に信頼ダイアログ等で止まると `agent_not_ready` が返る。ユーザーにタブで対応してもらい、`herdr agent wait <name>` で idle になるのを待つ。

## 5. 指示を出す

指示文には次の内容を含める。

- タスクの内容と完了条件
- 結果を `<結果ディレクトリ>/<name>.md` に書くこと（やったこと・変更ファイル・未解決事項）
- 権限が無くて拒否された操作は、別の手段で迂回せず、必要だったコマンドと理由を結果ファイルに書くこと
- commit・pushはしないこと

```bash
herdr agent prompt <name> "<指示文>" --wait --timeout 600000
```

長時間かかる場合は、Bashツールの `run_in_background` で `herdr agent wait <name>` を実行して、待っている間にメインの作業を進める。

`blocked` で返ったら、`herdr agent read <name> --source recent-unwrapped --lines 120` で状況を確認してユーザーに判断を仰ぐ。メインセッションが勝手に回答しない。

## 6. 結果を回収する

1. 結果ファイルを読む
2. implement の場合は `git -C <worktree> diff` で差分を確認する
3. 結果ファイルに書かれた「拒否された操作」は、メインセッションで必要性を判断して実行する
4. 差分をメインのブランチに取り込む

## 7. 片付ける

ユーザーに確認してから実行する。

```bash
herdr tab close <tab_id>
git worktree remove <worktree> && git branch -D <name>
```
