/**
 * App.tsx - アプリケーションのルートコンポーネント
 *
 * 役割:
 *   - カスタムフック（useAccounts / useTransfer）からデータと処理を取得する
 *   - 子コンポーネント（UserList / TransferForm）に必要な props を渡す
 *   - 送金成功後にアカウント一覧を再取得して残高を最新化する
 *
 * このコンポーネント自体はロジックを持たず、
 * 各フックとコンポーネントの接続のみを担う（オーケストレーター）。
 */
import { useAccounts } from './hooks/useAccounts'
import { useTransfer } from './hooks/useTransfer'
import { UserList } from './components/UserList'
import { TransferForm } from './components/TransferForm'
import styles from './App.module.css'

/**
 * ログイン中のユーザーID（固定値）。
 * 本来は認証システムから取得するが、このアプリでは固定の John アカウントを使用する。
 */
const MY_USER_ID = '906ae09d-3701-4f78-8fe1-9be221547148'

export default function App() {
  const { accounts, loading, refresh } = useAccounts()
  const { result, transfer } = useTransfer()

  // 自分の残高は accounts 配列から検索する（残高は useAccounts が管理）
  const myBalance = accounts.find(a => a.id === MY_USER_ID)?.balance

  /**
   * TransferForm から呼ばれる送金ハンドラー。
   * 送金成功時に refresh() でユーザー一覧の残高を更新する。
   */
  const handleTransfer = async (receiverId: string, amount: number): Promise<boolean> => {
    const success = await transfer({ sender_id: MY_USER_ID, receiver_id: receiverId, amount })
    if (success) await refresh()
    return success
  }

  return (
    <>
      <header className={styles.header}>
        <h1 className={styles.headerTitle}>ポイント送金アプリ</h1>
      </header>

      {/* レスポンシブ: PC は左右2カラム、スマホは1カラム（App.module.css 参照） */}
      <div className={styles.layout}>
        <section className={styles.panel}>
          <h2 className={styles.panelTitle}>ユーザー一覧</h2>
          <UserList accounts={accounts} loading={loading} myUserId={MY_USER_ID} />
        </section>

        <section className={styles.panel}>
          <h2 className={styles.panelTitle}>送金フォーム</h2>
          <TransferForm
            accounts={accounts}
            myUserId={MY_USER_ID}
            myBalance={myBalance}
            result={result}
            onSubmit={handleTransfer}
          />
        </section>
      </div>
    </>
  )
}
