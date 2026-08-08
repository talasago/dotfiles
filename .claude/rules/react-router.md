---
paths:
  - "**/router.tsx"
  - "**/router.ts"
  - "**/routes.tsx"
  - "**/routes.ts"
---

# react-router

前提：`createBrowserRouter`/`createMemoryRouter`等 + `RouterProvider`を使うData Router構成の話。`<BrowserRouter><Routes>`等のDeclarative Router構成では`useMatches()`は使えない（Data Routerのコンテキストを要求し実行時エラーになる）。

react-routerは既定（ルートに`caseSensitive`を指定しない場合）では、URLのマッチング時に大文字小文字・末尾スラッシュの違いを無視する（`/settings`・`/Settings`・`/settings/`はいずれも同じルートにマッチする。`caseSensitive: true`を指定したルートは対象外）。一方`useLocation().pathname`はルーターが管理するlocationのpathnameであり、実際にアクセスされた表記をそのまま保持する。`basename`指定時や`HashRouter`・`MemoryRouter`使用時は`window.location.pathname`と一致しない点にも注意（`useLocation().pathname`をブラウザの生のpathnameと同一視しない）。

そのため、特定の画面でのみ処理を分岐させたい場合（例：ある画面でだけモーダルを表示する）に`location.pathname === '/settings'`のような文字列の厳密一致で判定すると、ルート自体は正しくマッチして画面が表示されているのに、`/Settings`・`/settings/`等の表記では分岐条件だけがすり抜けてしまう。

ルートに対応した分岐は、`location.pathname`の文字列比較ではなく、実際にマッチしたルートの識別情報で判定する。ルート定義に`id`を付与し、`useMatches()`で判定する。ネストしたルート構成では`useMatches()`の末尾要素はleaf routeのmatchになるため、「特定の1画面か」の判定には使えるが、「子ルートを含めた親ルート配下がアクティブか」の判定には使えない（全matchを走査する）。

```tsx
// ルート定義側で id を付与する
{ path: 'settings', id: 'settings', element: <SettingsRoute /> }
```

```tsx
// leaf routeの判定（そのものが表示されているか）
const matches = useMatches()
const isSettingsRoute = matches.at(-1)?.id === 'settings'

// 子ルートを含めた親ルート配下がアクティブかどうかの判定
const isUnderSettings = matches.some((m) => m.id === 'settings')
```

## 注意：判定ロジックの置き場所

このルールは`paths`でルーター定義ファイルにのみ自動読み込みされる。実際の分岐ロジック（`useLocation`・`useMatches`を使った条件分岐）は別のコンポーネントやカスタムフックに書かれることが多く、その場合はこのルールが自動発火しない。ルート定義を変更・確認する際は、対応する分岐ロジックがどのファイルにあるかもあわせて確認する。
