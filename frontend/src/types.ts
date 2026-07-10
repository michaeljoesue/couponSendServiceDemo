/** バックエンドの /api/accounts レスポンスに対応する型 */
export type Account = {
  id: string
  username: string
  balance: number
}

/** POST /api/balances のリクエストボディ */
export type TransferPayload = {
  sender_id: string
  receiver_id: string
  amount: number
}

/**
 * 送金処理の状態を表すユニオン型。
 * - idle:    初期状態（何も起きていない）
 * - loading: API 呼び出し中（ボタン無効化に使用）
 * - success: 送金成功（メッセージ表示 + フォームリセット）
 * - error:   送金失敗（メッセージ表示・フォームはリセットしない）
 */
export type TransferResult =
  | { type: 'idle' }
  | { type: 'loading' }
  | { type: 'success'; message: string }
  | { type: 'error'; message: string }
