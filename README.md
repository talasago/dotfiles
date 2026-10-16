# dotfiles

## ステータスライン（ccstatusline）

Claude Code のステータスラインに [ccstatusline](https://github.com/sirmalloc/ccstatusline) を使う。

```bash
npm install -g ccstatusline
./install_dotfiles.bash
```

- Claude Code 側の登録は `.claude/settings.json` の `statusLine`。`install_ai_rules.bash` が `~/.claude/settings.json` を新規作成するときだけ反映される。既存の `~/.claude/settings.json` に `statusLine` がある場合はそちらが優先される。
- 表示内容は `.config/ccstatusline/settings.json`。
