# 送金アプリ バックエンド

## 概要

このバックエンドは、送金アプリのサーバーサイドロジックを提供します。Ruby on Rails で書かれており、SQLite データベースを使用してデータを管理します。API は、アカウント管理、残高照会、残高更新、送金処理をサポートしています。

## 必要なバージョン

- **Ruby**: 3.2.2
- **Rails**: 7.1.2

## プロジェクト構造

```
backend/
├── app/
│   ├── controllers/           # HTTPコントローラー
│   │   └── api/
│   │       ├── accounts_controller.rb   # アカウント関連コントローラー
│   │       └── balances_controller.rb   # 残高関連コントローラー
│   ├── models/                # データモデル
│   │   ├── account.rb         # Accountモデル
│   │   ├── balance.rb         # Balanceモデル
│   │   └── transaction_log.rb # TransactionLogモデル
│   ├── services/              # ビジネスロジック
│   │   ├── money_transfer_service.rb    # 送金サービス
│   │   └── transaction_log_service.rb   # トランザクションログサービス
│   └── validators/            # バリデーター
│       └── balance_validator.rb         # 残高バリデーター
├── config/
│   └── routes.rb              # ルーティング設定
├── db/
│   ├── migrate/               # マイグレーションファイル
│   └── seeds.rb               # 初期データ投入
├── spec/                      # テストコード
├── Dockerfile                 # Docker設定
├── Gemfile                    # Gem依存関係
└── README.md                  # このファイル
```

## 詳細情報

[Ruby on Rails のドキュメント](https://guides.rubyonrails.org/v7.1/index.html)で詳細を学ぶことができます。
