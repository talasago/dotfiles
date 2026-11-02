---
description: 投稿済みのGitHub PR本文・Issue本文・コメントを更新するとき、更新の直前に現在の本文を取得し直し、他者の編集を消さないようにする。
when_to_use: 既存のPR本文（description）・Issue本文・コメントを gh pr edit / gh issue edit / gh api PATCH などで更新する、PRのdescriptionを書き換える、refetch-before-edit-description-pr
---

# refetch-before-edit-description-pr

## 対象

- PR本文（description）
- Issue本文
- Issue/PRコメント

## 手順

1. 更新の直前に、現在の本文をGitHubから取得する（`gh pr view <number> --json body --jq .body` 等）。ローカルに保存した本文や、会話内で以前に作った本文は使わない
2. 取得した本文を土台に、変更する箇所だけを直す。全文を再生成して `--body-file` で差し替えない
3. 取得した本文に対する差分をユーザーに示し、承認を得てから更新する
   - チェックボックスの状態・Jira等のリンク・人が書いた記述が消えていないことを確認する
4. 前回の自分の更新以降に、GitHub上で他者（ユーザーが手で行った編集を含む）の編集が入っていたら、更新前にユーザーへ伝える

## 消してしまった場合

編集履歴から各時点の本文を取得できる。

```bash
gh api graphql -f query='query { repository(owner:"OWNER", name:"REPO") { pullRequest(number:N) { userContentEdits(first:20) { nodes { createdAt diff } } } } }'
```

消えた編集を特定し、現在の本文にその箇所だけを足し戻す。
