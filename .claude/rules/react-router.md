---
paths:
  - "**/router.tsx"
  - "**/router.ts"
  - "**/routes.tsx"
  - "**/routes.ts"
---

# react-router

react-routerは、URLのマッチング時に大文字小文字・末尾スラッシュの違いを無視する（`/settings`・`/Settings`・`/settings/`はいずれも同じルートにマッチする）。一方`useLocation().pathname`（ブラウザの`window.location.pathname`をそのまま反映する値）は、実際にアクセスされた表記をそのまま保持する。

そのため、特定の画面でのみ処理を分岐させたい場合（例：ある画面でだけモーダルを表示する）に`location.pathname === '/settings'`のような文字列の厳密一致で判定すると、ルート自体は正しくマッチして画面が表示されているのに、`/Settings`・`/settings/`等の表記では分岐条件だけがすり抜けてしまう。

ルートに対応した分岐は、`location.pathname`の文字列比較ではなく、実際にマッチしたルートの識別情報で判定する。ルート定義に`id`を付与し、`useMatches()`が返す配列の末尾要素の`id`を見るのが素直。

```tsx
// ルート定義側で id を付与する
{ path: 'settings', id: 'settings', element: <SettingsRoute /> }
```

```tsx
// 判定側
const matches = useMatches()
const currentRouteId = matches.at(-1)?.id
const isSettingsRoute = currentRouteId === 'settings'
```
