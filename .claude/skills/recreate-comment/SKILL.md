---
description: 投稿済みのGitHubのIssueコメント・PRコメント・Issue本文がまずい内容だったと気づいたときの訂正手順。編集ではなくdelete→createでやり直す。
when_to_use: 投稿済みのGitHub Issueコメント・PRコメント・Issue本文の内容がまずかった、書くべきでなかったと気づいたとき、recreate-comment
---

# recreate-comment

## 対象

- Issueコメント
- PRコメント
- Issue本文

## まずいコメント・Issue本文に気づいたら

- **編集（PATCH）ではまずい内容が消えない。GitHubは編集履歴を保持するため。delete → create でやり直す**
  - IDと番号・URLが変わるので、他所からリンクしていたら貼り直す
  - 複数コメントがあるなら元の並び順で作り直す
- 誤字修正など、まずくない変更は編集（PATCH）のままでよい

## gh CLI が使える環境

- Issue/PRコメント: `gh api -X DELETE repos/OWNER/REPO/issues/comments/<id>` → `gh issue comment` 等で作り直す
- Issue本文: `gh issue delete <number>` → `gh issue create` で作り直す

## GitHub MCP しか使えない環境（Claude Code on the web 等）

コメントの編集・削除、Issueの削除に対応するツールが無いため、自力では消せない。

1. 訂正後の内容をユーザーに提示し、投稿の可否を確認する
2. 承認を得たら新しいコメントとして投稿する
3. 元のコメントの削除をユーザーに依頼する。URLとコメントIDを示す
