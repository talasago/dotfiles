---
description: Vitestでテストを新規作成・追加・修正するとき。TypeScriptのテスト構造、命名、配置規則を適用する。
when_to_use: Vitest、TypeScript、*.test.ts、*.test.tsx、it.each、describe.each
---

# write-vitest

Vitest固有のテスト実装ルール。共通のテスト設計方針は`/write-test`を参照する。

## テスト構造

- `describe`・`it`ブロックでテストを構造化する
- `describe`にはテスト対象のクラス名・機能名・メソッド名を記述する
- 前提条件は`describe`のネストで表現し、`when`または`if`から始まる文で記述する
- 条件が3パターン以上になる場合は`it.each`または`describe.each`を使用する

## AAAパターン

- Arrange：`const`変数や`beforeEach`でセットアップする
- Act：SUTの呼び出し結果を変数に代入する
- Assert：`expect`と適切なマッチャーで検証する
