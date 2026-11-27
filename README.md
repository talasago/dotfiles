# dotfiles

## Codex で共有の指示とスキルを使う

このリポジトリで Codex を開くと、`.agents/skills` のリンク経由で `$write-test` などを呼び出せる。スキルの編集先は `.claude/skills/`。

他のリポジトリでも使うには、ローカルで `./install_ai_rules.bash --environment local --target codex`、クラウドのセットアップ環境で `./install_ai_rules_for_cloud.bash --target codex` を実行する。Claude Code も同時に設定する場合は `--target all` を使う。スキルを追加したらインストーラーを再実行する。

## ステータスライン（ccstatusline）

Claude Code のステータスラインに [ccstatusline](https://github.com/sirmalloc/ccstatusline) を使う。

```bash
npm install -g ccstatusline
./install_dotfiles.bash
```

- Claude Code 側の登録は `.claude/settings.json` の `statusLine`。`install_ai_rules.bash` が `~/.claude/settings.json` を新規作成するときだけ反映される。既存の `~/.claude/settings.json` に `statusLine` がある場合はそちらが優先される。
- 表示内容は `.config/ccstatusline/settings.json`。
