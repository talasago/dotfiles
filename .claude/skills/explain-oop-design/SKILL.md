---
description: 実務コードを読み、SOLID原則とデザインパターンのどれがどこに当てはまるかを学習目的で解説する。直すならどう書くかも示すが、直すべきかの判断はしない。
when_to_use: SOLID的にどう、どのデザパタ、OOPの観点で解説して、explain-oop-design
argument-hint: "[ファイルパス or ディレクトリ]"
allowed-tools: Read Grep Glob
---

# explain-oop-design

`$ARGUMENTS` のコードを読み、SOLID原則とデザインパターンの観点で解説する。目的はユーザーの学習であり、コードの良し悪しの判定ではない。

## 観点

- SOLID：5原則すべて
- デザインパターン：
  - GoF：Observer・Decorator・Facade・Proxy・Command・State・Composite・Singleton・Chain of Responsibility
  - PoEAA（Martin Fowler『Patterns of Enterprise Application Architecture』）：Active Record・Data Mapper・Repository・Service Layer・Unit of Work・Gateway・Lazy Load・Data Transfer Object・Value Object
  - その他：Dependency Injection・Null Object
  - 理由を書くときは、どのカタログの定義に基づくかを示す
  - フレームワークが提供している仕組みがパターンの実例になっている場合も挙げる（例：Rails のコールバックや Django のシグナルは Observer、Rack や Django のミドルウェアは Chain of Responsibility）
- React のコードでは、関数コンポーネントとフックは読み飛ばし、そこから使われるクラスベースのコード（APIクライアント・ストア・ドメインモデル等）を見る

## 出力

見つけた箇所ごとに以下を書く。

1. **該当箇所**：`file_path:line_number`
2. **原則・パターン名**と**そう言える理由**：定義のどの部分に当たるかを示す。業務上の文脈（変更理由がどう分かれるか等）によって結論が変わるものは「文脈しだい」と明記する
3. **直すなら**：書き換えの方向性と短いコード例。直すべきかどうかの判断・推奨はしない
4. **前提知識**：ダックタイピング、is-a / has-a、コンポジション、インターフェース等が理由の説明に出てきたら、初出時に2〜3行で説明する

最後に、当てはまらなかったSOLIDの原則それぞれについて、なぜこのコードではその原則の話にならないかを1行ずつ書く。動的型付け言語では L・I はダックタイプ（同じメッセージに応えるもの同士の置き換え、役割の大きさ）の形で現れることを踏まえて判断する。
