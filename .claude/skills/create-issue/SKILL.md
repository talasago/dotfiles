---
description: GitHub Issue・SubIssueを作成するとき。既存Issueの事前確認と、SubIssueの分割原則（1成果物・依存最小・レビュー可能な最小単位）を適用する。
when_to_use: Issueを作って、Issueを起票して、SubIssueに分割して、create-issue
---

# create-issue

## Issue 作成前の確認

- Issue を作成する前に `list_issues`（ローカルCLIでは `gh issue list`）で既存 Issue を確認する。
- 重複だけでなく関連 Issue も把握してから作成する。

## issueとsubissueの関係性

issueは大きい粒度。

SubIssueは次の原則で分割する。

- 1つの明確な成果物を持つこと
- 他のSubIssueへの依存を最小限にする
- 前のSubIssueの成果物だけで開始できること
- 1つのSubIssueで複数の責務を持たせない
- 調査・実装・レビューを必要以上に混在させない
- SubIssueはレビュー可能な最小単位

良い例

- 計測ロジック + 単体テスト
- 画面実装 + CSS

悪い例

- 認証改善
- API全体修正
- DB・API・Frontendをまとめて変更
