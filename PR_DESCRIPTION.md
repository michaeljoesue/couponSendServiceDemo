# feat: ポイント送金システムの設計・実装（フロントエンド + バックエンド）

## 概要

Issue #1 に基づき、ポイント送金アプリのシステム設計・実装を行いました。
このPRでは **システム全体の仕組み** を説明します。

---

## システム構成

```
ブラウザ (port 3000)
    │  HTTP リクエスト
    ▼
フロントエンド: React + TypeScript + Vite
    │  fetch API
    ▼
バックエンド: Ruby on Rails (port 8080)
    │  ActiveRecord
    ▼
データベース: SQLite
```

Docker Compose で `frontend` と `backend` の2つのコンテナが同一ネットワーク上で起動します。

---

## バックエンドの仕組み

### APIエンドポイント一覧

| メソッド | パス | 用途 |
|---|---|---|
| `GET` | `/api/accounts` | 全ユーザー一覧（名前・残高）を返す |
| `GET` | `/api/accounts/:id` | 特定ユーザーの詳細を返す |
| `POST` | `/api/balances` | ポイント送金を実行する |
| `GET` | `/api/transaction_logs?account_id=` | 取引履歴を返す |

### 送金処理のフロー

`POST /api/balances` を受け取ったときの処理の流れです。

```
POST /api/balances
{ sender_id, receiver_id, amount }
        │
        ▼
BalancesController#create
        │ amount を整数に変換（params は文字列で渡されるため）
        ▼
MoneyTransferService#call
        │
        ├─ validate!（DB アクセス前の入力値チェック）
        │       ├─ sender / receiver が存在するか
        │       ├─ 自己送金でないか
        │       └─ amount が正の整数か
        │
        ├─ transfer_balances（DBトランザクション）
        │       ├─ sender の残高が足りるか確認
        │       ├─ sender の残高を減算
        │       └─ receiver の残高を加算
        │         ↑ どちらかが失敗した場合、両方ロールバック
        │
        └─ log_transaction（トランザクション外で実行）
                └─ TransactionLog に success / failed を記録
```

> **設計上のポイント**: 成功ログの記録をトランザクション外に置いています。
> トランザクション内に置くと、ログ作成の失敗が残高更新のロールバックを引き起こすためです。
> ポイントの移動確定をログ記録より優先する設計です。

### エラーハンドリング

`ApplicationController` に `rescue_from` を集約することで、各コントローラーに `rescue` ブロックを書かずに済む構成にしています。

| 例外クラス | HTTPステータス |
|---|---|
| `MoneyTransferService::AccountNotFoundError` | `404 Not Found` |
| `MoneyTransferService::InvalidTransferError` | `400 Bad Request` |
| `MoneyTransferService::InsufficientBalanceError` | `400 Bad Request` |
| `MoneyTransferService::TransferError` | `500 Internal Server Error` |
| `ActiveRecord::RecordNotFound` | `404 Not Found` |
| `BalanceValidator::ValidationError` | `400 Bad Request` |

### データベース構成

```
accounts テーブル
  id (UUID文字列), username

balances テーブル
  account_id (FK → accounts), value

transaction_logs テーブル
  sender_id (FK → accounts), receiver_id (FK → accounts),
  amount, status (success / failed), transaction_date
```

---

## フロントエンドの仕組み

### ファイル構成と責務

```
src/
├── App.tsx              # 各フックとコンポーネントをつなぐオーケストレーター
├── App.module.css       # 2カラムレイアウト・レスポンシブ対応
├── types.ts             # 共通型定義（Account / TransferPayload / TransferResult）
│
├── hooks/
│   ├── useAccounts.ts   # GET /api/accounts の取得・更新管理
│   └── useTransfer.ts   # POST /api/balances の呼び出しと状態管理
│
└── components/
    ├── UserList.tsx      # 全ユーザーの一覧表示
    └── TransferForm.tsx  # 送金フォーム（バリデーション込み）
```

### 送金時のデータフロー

```
【入力中 - リアルタイムバリデーション】

送金相手を選択
        └─ onChange → 未選択なら「送金相手を選択してください」表示
                      選択済みなら緑枠でOK表示

金額を入力
        ├─ onChange → かな・漢字・記号を即時除去（数字のみ残す）
        ├─ 0以下 / 非数値   → 赤枠 + 「1以上の整数を入力してください」
        ├─ 残高超過         → 赤枠 + 「残高を超える金額は送金できません」
        └─ 正常             → 緑枠

※ 自己送金はドロップダウンから自分を除外することで入力不可にしている

【送金ボタン押下】

        ├─ 未入力フィールドがあれば最終チェックでエラー表示（API呼ばない）
        │
        └─ 全フィールド正常
                │
                ▼
        useTransfer: POST /api/balances
                │
                ├─ 成功 → ✓ メッセージ表示
                │         フォームをリセット
                │         useAccounts.refresh() でユーザー一覧の残高を更新
                │
                └─ 失敗 → ! エラーメッセージ表示
                          フォームはリセットしない（修正して再送信可能）
```

### バリデーションの仕組み

| フィールド | タイミング | チェック内容 |
|---|---|---|
| 送金相手 | 選択した瞬間（onChange） | 未選択でないか |
| 金額 | 入力のたびリアルタイム（onChange） | 数字のみ・1以上・残高以内 |
| 送信ボタン押下 | 全フィールドの最終チェック | 未入力フィールドを検出 |

数字以外（かな・漢字・アルファベット・記号）は `onChange` で即時除去するため、入力欄には数字しか入らない設計になっています。

### レスポンシブ対応

```css
/* PC（641px以上）: 左右2カラム */
.layout { display: flex; }

/* スマホ（640px以下）: 上下1カラム */
@media (max-width: 640px) {
  .layout { flex-direction: column; }
}
```

---

## 動作確認手順

```bash
# 起動
docker compose up --build

# フロントエンド
open http://localhost:3000

# バックエンドAPIの確認
curl http://localhost:8080/api/accounts

curl -X POST http://localhost:8080/api/balances \
  -H 'Content-Type: application/json' \
  -d '{"sender_id":"906ae09d-3701-4f78-8fe1-9be221547148","receiver_id":"181cd98b-d1a8-46a3-bc77-a0ed4d40f702","amount":1000}'

curl "http://localhost:8080/api/transaction_logs?account_id=906ae09d-3701-4f78-8fe1-9be221547148"
```

---

## 変更ファイル

### 新規作成

| ファイル | 内容 |
|---|---|
| `backend/app/controllers/api/transaction_logs_controller.rb` | 取引履歴APIコントローラー |
| `frontend/src/hooks/useAccounts.ts` | アカウント取得カスタムフック |
| `frontend/src/hooks/useTransfer.ts` | 送金処理カスタムフック |
| `frontend/src/components/UserList.tsx` | ユーザー一覧コンポーネント |
| `frontend/src/components/TransferForm.tsx` | 送金フォームコンポーネント |
| `frontend/src/App.module.css` | アプリレイアウトCSS |

### 修正

| ファイル | 変更内容 |
|---|---|
| `backend/app/controllers/application_controller.rb` | `rescue_from` によるエラーハンドリング集約 |
| `backend/app/services/money_transfer_service.rb` | 成功ログのトランザクション外移動・バグ修正 |
| `backend/app/controllers/api/accounts_controller.rb` | `find_by!` に修正（誤った例外捕捉のバグ修正） |
| `backend/app/controllers/api/balances_controller.rb` | 重複 `rescue` ブロックを削除 |
| `backend/app/models/transaction_log.rb` | アソシエーション・バリデーション・スコープ追加 |
| `backend/app/models/balance.rb` | `value >= 0` バリデーション追加 |
| `backend/app/models/account.rb` | 送受信アソシエーション追加 |
| `frontend/src/App.tsx` | フロントエンド全面実装 |
| `frontend/src/types.ts` | 共通型定義の追加 |
