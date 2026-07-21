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

## 非同期モックの解決タイミングを後から制御する

`mockImplementation`等で返すPromiseの resolve/reject を、テスト内の後続処理から任意のタイミングで呼び出したい場合、そのコールバックを`let`変数に代入して後で呼び出す書き方をしない。TypeScriptの制御フロー解析は、ネストしたクロージャ内でのみ再代入される`let`変数を後続の参照時に誤って`never`型へ絞り込むことがあり、意図しない型エラーになる。

代わりにオブジェクトのプロパティとして保持する。

```ts
// 避ける：後続の呼び出しでTSに`never`型へ誤って絞り込まれることがある
let resolveFirst: (() => void) | null = null

// 推奨：オブジェクトのプロパティ経由で保持する
const firstCall: { resolve: (() => void) | null } = { resolve: null }
vi.spyOn(target, 'method').mockImplementation(() => new Promise((resolve) => {
  firstCall.resolve = () => resolve(undefined)
}))
// ...
firstCall.resolve?.()
```
