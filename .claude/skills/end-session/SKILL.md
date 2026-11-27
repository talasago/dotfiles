---
name: end-session
description: ユーザーが明示的に依頼したときに実行する。セッションを終えるときの後片付け。record-ai-review と record-learning-gaps で記録を残してから、作業が終わった git worktree とそのローカルブランチを削除する。
---

# end-session

記録 → worktree 削除の順に進める。今いる worktree を消すと以降の作業ディレクトリが無くなるため、削除は最後にする。

## 1. 記録する

同じスキルディレクトリにある次の手順を順に実行する。

1. [record-ai-review](../record-ai-review/SKILL.md)（記録モード）
2. [record-learning-gaps](../record-learning-gaps/SKILL.md)

## 2. 削除候補を洗い出す

`git worktree list --porcelain` で、今いるリポジトリの worktree を一覧する。メインの worktree は対象にしない。以下のいずれかに当たるものを候補にする。

- 今いる worktree（`git rev-parse --git-dir` と `--git-common-dir` が異なる）
- herdr-sub-session が作った `<repo>-worktrees/<name>` 配下の worktree
- ブランチがマージ済みの worktree。`git branch --merged origin/<既定ブランチ>` に含まれるか、`gh pr list --head <branch> --state merged` でマージ済みPRがあるもの（スカッシュマージは前者で検出できない）

detached HEAD の worktree は、別のツールが管理している場合があるため候補にしない。

## 3. 消してよいか確認する

候補ごとに以下を確認し、1つでも当たれば削除しない。

- 未コミットの変更：`git -C <worktree> status --porcelain` が空でない（未追跡ファイルを含む）
- 未pushのコミット：`git -C <worktree> log --oneline <branch> --not --remotes` が空でない。ただし、マージ済みPRの `headRefOid`（`gh pr list --head <branch> --state merged --json headRefOid`）がブランチ先端と一致する場合は push 済みとみなす（マージ後にリモートブランチが消えたケース）

結果を表でチャットに出し、削除してよいかユーザーに確認する。

| worktree | ブランチ | 候補の理由 | 判定 |
|---|---|---|---|
| path/to/worktree | feature-x | マージ済み | 削除 |
| path/to/other | feature-y | herdr | 残す（未コミットあり） |

## 4. 削除する

承認された worktree ごとに、メインの worktree を起点に実行する。今いる worktree は最後に消す。

```bash
git -C <メインのworktree> worktree remove <worktree> && git -C <メインのworktree> branch -D <branch>
```

`branch -D` を使うのは、スカッシュマージしたブランチが `-d` では消せないため。3. で未push のコミットが無いことは確認済み。

このセッションで EnterWorktree して入った worktree は、`git worktree remove` ではなく ExitWorktree（`action: remove`）で消す。

残した worktree があれば、その理由と合わせて最後に報告する。
