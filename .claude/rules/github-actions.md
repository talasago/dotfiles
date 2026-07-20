---
paths:
  - ".github/workflows/**"
---

# GitHub Actions のバージョン固定

`uses:` に指定するバージョンはタグ（`@v4`）ではなくコミットハッシュ（`@<sha>`）で固定する。
タグは書き換え可能でサプライチェーン攻撃のリスクがある。
ハッシュにはコメントでタグ名を併記して可読性を補う。

```yaml
# 良い例
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1

# 悪い例
- uses: actions/checkout@v4
- uses: actions/checkout@main
```

ハッシュの確認方法：`git ls-remote https://github.com/<owner>/<repo>.git --tags '<tag>'`
