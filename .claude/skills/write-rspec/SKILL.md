---
description: RSpecでテストを新規作成・追加・修正するとき。RSpec、Rails、Shoulda Matchersの規約を適用する。
when_to_use: RSpec、Rails、spec、Shoulda Matchers、rspec-parameterized、write-rspec
---

# write-rspec

RSpec固有のテスト実装ルール。共通のテスト設計方針は`/write-test`を参照する。

## 構造ルール

- `describe`、`context`、`it`ブロックを使用してテストを構造化する
- `it`ブロックにはshouldを使用して期待すべき動作を記述する
- `describe`はテスト対象の機能名やメソッド名を記述する
- `context` は前提条件（状態、フラグ、権限など）を when から始まる文で記述する
  - テスト対象や機能名の記述には使用しない
- 新しい `context` を追加する際は、既存の `context` 階層を確認し、そのテストが前提とするデータや状態を提供する親 `context` の中にネストする
  - 安易に `describe` レベルに追加しない
- 同じインデントで `context` が3つ以上存在する、またはパラメータ駆動のほうが行数が少ない場合、`rspec-parameterized` を使用する
- 1つの `describe` に複数の前提条件がある場合は `context` で分ける
- 1つの `describe` に1つの `context` は冗長なため不要

## AAAパターン

- Arrange：`let`、`let!`、`before`でセットアップする
- Act：`subject`でSUT（System Under Test）を表し、各`describe`の下にメソッドごとに定義する
- Assert：`expect`と適切なマッチャーで検証する
- `let`（遅延評価）を活用してコード量を減らす
- クラスの初期化引数やメソッドのパラメータなど、コンテキストによって変わる変数は、外部スコープで `let` にデフォルト値を定義する
- 内部の describe/context ブロックでは、`let` のオーバーライドのみで条件を変更する。セットアップ全体を再定義しない
- 既存のspecにテストを追加する際は、内部スコープだけで新しい変数を定義するのではなく、外部スコープの `let` にデフォルト値を追加することを検討する


## Shoulda Matchers（モデルスペック用）
- アソシエーション、バリデーション、コールバックには可能な限り Shoulda Matchers を使用する
- Shoulda Matchers で表現できない複雑なバリデーションやロジックのみ手動でテストを記述する
- 1行で簡潔に記述できるマッチャーを優先する

## コードスタイル
- クラス名をハードコードせず `described_class` を使用する
- ワンライナースペックには `is_expected` を使用する
- コードのコメントは英語で記述する
- ファイル先頭に `frozen_string_literal: true` を含める
- 必ず `require 'rails_helper'` から始める
