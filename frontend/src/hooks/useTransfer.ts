import { useState } from 'react'
import { TransferPayload, TransferResult } from '../types'

const API_BASE_URL = 'http://localhost:8080'

type UseTransferReturn = {
  /** 送金処理の現在の状態（idle / loading / success / error） */
  result: TransferResult
  /**
   * 送金を実行する関数。
   * @returns 送金が成功した場合 true、失敗した場合 false
   */
  transfer: (payload: TransferPayload) => Promise<boolean>
}

/**
 * 送金API呼び出しと結果状態の管理を担うカスタムフック。
 *
 * 戻り値の result を見て、呼び出し元（TransferForm）が
 * 成功メッセージ・エラーメッセージ・ローディング表示を切り替える。
 *
 * transfer() の戻り値（boolean）でフォームリセットの制御を行う:
 *   true  → 送金成功 → フォームをリセットしてよい
 *   false → 送金失敗 → フォームをリセットしない（入力内容を保持して再送信可能にする）
 */
export function useTransfer(): UseTransferReturn {
  const [result, setResult] = useState<TransferResult>({ type: 'idle' })

  const transfer = async (payload: TransferPayload): Promise<boolean> => {
    setResult({ type: 'loading' })

    try {
      const res = await fetch(`${API_BASE_URL}/api/balances`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
      const data = await res.json()

      if (res.ok) {
        setResult({
          type: 'success',
          message: `送金が完了しました。残高: ${(data.balance as number).toLocaleString()} pt`,
        })
        return true
      }

      // API エラー（残高不足・自己送金など）はフォームをリセットしない
      setResult({ type: 'error', message: data.error ?? '送金に失敗しました。' })
      return false
    } catch {
      // ネットワーク障害など fetch 自体が失敗したケース
      setResult({ type: 'error', message: 'ネットワークエラーが発生しました。' })
      return false
    }
  }

  return { result, transfer }
}
