import { Account } from '../types'
import styles from './UserList.module.css'

/**
 * UUID の前4文字と後4文字だけを残し、中間をマスクして表示する。
 * 例: "906ae09d-3701-4f78-8fe1-9be221547148" → "906a****7148"
 * プライバシー配慮のため、フルIDをそのまま画面に出さないようにしている。
 */
const maskId = (id: string) => `${id.slice(0, 4)}****${id.slice(-4)}`

type Props = {
  accounts: Account[]
  /** API 取得中は true。ローディング表示の切り替えに使用 */
  loading: boolean
  /** 自分のアカウントID。"あなた" バッジとハイライト表示に使用 */
  myUserId: string
}

/**
 * 全ユーザーの一覧を表示するコンポーネント。
 * - 自分のアカウントは青枠・"あなた" バッジで強調表示する
 * - 送金成功後は親（App）が useAccounts.refresh() を呼び、
 *   accounts が更新されることで残高が自動的に再描画される
 */
export function UserList({ accounts, loading, myUserId }: Props) {
  if (loading) {
    return <p className={styles.loading}>読み込み中...</p>
  }

  return (
    <ul className={styles.list}>
      {accounts.map(account => {
        const isMe = account.id === myUserId
        return (
          <li key={account.id} className={`${styles.item} ${isMe ? styles['item--me'] : ''}`}>
            <div className={styles.top}>
              <span className={styles.username}>{account.username}</span>
              {isMe && <span className={styles.badge}>あなた</span>}
              <span className={styles.balance}>{account.balance.toLocaleString()} pt</span>
            </div>
            <div className={styles.bottom}>
              <span>ID: {maskId(account.id)}</span>
              <span>残高</span>
            </div>
          </li>
        )
      })}
    </ul>
  )
}
