import { useState, useEffect, useCallback } from 'react'
import { Account } from '../types'

const API_BASE_URL = 'http://localhost:8080'

type UseAccountsReturn = {
  accounts: Account[]
  loading: boolean
  /** 送金成功後に呼び出してユーザー一覧の残高を最新化する */
  refresh: () => Promise<void>
}

/**
 * 全ユーザーアカウントの取得・管理を担うカスタムフック。
 *
 * - 初回マウント時に自動でアカウント一覧を取得する
 * - refresh() を呼ぶことで再取得できる（送金後の残高更新に使用）
 * - loading フラグでデータ取得中の状態をコンポーネントに伝える
 */
export function useAccounts(): UseAccountsReturn {
  const [accounts, setAccounts] = useState<Account[]>([])
  const [loading, setLoading] = useState(true)

  // useCallback でメモ化することで、useEffect の依存配列に安全に渡せる
  const refresh = useCallback(async () => {
    const res = await fetch(`${API_BASE_URL}/api/accounts`)
    if (!res.ok) throw new Error('アカウント取得に失敗しました')
    const data: Account[] = await res.json()
    setAccounts(data)
  }, [])

  useEffect(() => {
    // finally で loading を必ず解除し、エラー時も無限ローディングにならないようにする
    refresh().finally(() => setLoading(false))
  }, [refresh])

  return { accounts, loading, refresh }
}
