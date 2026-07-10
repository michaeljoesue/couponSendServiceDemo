import { useState, FormEvent } from 'react'
import { Account, TransferResult } from '../types'
import styles from './TransferForm.module.css'

type Props = {
  accounts: Account[]
  myUserId: string
  myBalance: number | undefined
  result: TransferResult
  onSubmit: (receiverId: string, amount: number) => Promise<boolean>
}

/** フィールドごとのバリデーションエラー */
type FieldErrors = {
  receiver?: string
  amount?: string
}

/**
 * 送金フォームコンポーネント。
 *
 * バリデーション方針:
 * - 金額: 入力のたびにリアルタイムでチェック（onChange）
 * - 送金相手: 選択したタイミングでチェック（onChange）
 * - 送信ボタン押下時: 全フィールドを最終チェック
 *
 * 文字入力対策:
 * - type="text" + inputMode="numeric" を使用
 * - onChange で数字以外を即時除去（かな・漢字・e・記号すべて防止）
 */
export function TransferForm({ accounts, myUserId, myBalance, result, onSubmit }: Props) {
  const [receiverId, setReceiverId] = useState('')
  const [amount, setAmount] = useState('')
  const [errors, setErrors] = useState<FieldErrors>({})

  const isLoading = result.type === 'loading'
  const parsedAmount = parseInt(amount, 10)
  const isAmountValid = amount !== '' && !isNaN(parsedAmount) && parsedAmount > 0
  const isOverBalance = isAmountValid && myBalance !== undefined && parsedAmount > myBalance
  const isAmountInvalid = amount !== '' && (!isAmountValid || isOverBalance)

  /** 金額フィールドのバリデーション（リアルタイム） */
  const validateAmount = (val: string) => {
    const parsed = parseInt(val, 10)
    const isNum = val !== '' && !isNaN(parsed)

    if (val === '') {
      setErrors(prev => ({ ...prev, amount: undefined }))
    } else if (!isNum || parsed <= 0) {
      setErrors(prev => ({ ...prev, amount: '1以上の整数を入力してください' }))
    } else if (myBalance !== undefined && parsed > myBalance) {
      setErrors(prev => ({ ...prev, amount: '残高を超える金額は送金できません' }))
    } else {
      setErrors(prev => ({ ...prev, amount: undefined }))
    }
  }

  /** 送金相手フィールドのバリデーション */
  const validateReceiver = (val: string) => {
    if (!val) {
      setErrors(prev => ({ ...prev, receiver: '送金相手を選択してください' }))
    } else {
      setErrors(prev => ({ ...prev, receiver: undefined }))
    }
  }

  /**
   * 金額の onChange ハンドラー。
   * 数字以外（かな・漢字・アルファベット・記号）を除去してからセットする。
   */
  const handleAmountChange = (raw: string) => {
    const digitsOnly = raw.replace(/[^0-9]/g, '')
    setAmount(digitsOnly)
    validateAmount(digitsOnly)
  }

  /** 送信前の最終チェック */
  const validateAll = (): FieldErrors => {
    const next: FieldErrors = {}
    if (!receiverId) next.receiver = '送金相手を選択してください'
    if (amount === '') {
      next.amount = '金額を入力してください'
    } else if (!isAmountValid) {
      next.amount = '1以上の整数を入力してください'
    } else if (isOverBalance) {
      next.amount = '残高を超える金額は送金できません'
    }
    return next
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    const next = validateAll()
    if (Object.keys(next).length > 0) {
      setErrors(next)
      return
    }
    setErrors({})
    const success = await onSubmit(receiverId, parsedAmount)
    if (success) {
      setReceiverId('')
      setAmount('')
    }
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit} noValidate>

      {/* 送金相手 */}
      <div className={styles.field}>
        <label className={styles.label} htmlFor="receiver">送金相手</label>
        <select
          id="receiver"
          className={`${styles.select} ${
            errors.receiver ? styles['select--error'] :
            receiverId      ? styles['select--valid'] : ''
          }`}
          value={receiverId}
          onChange={e => { setReceiverId(e.target.value); validateReceiver(e.target.value) }}
          disabled={isLoading}
        >
          <option value="">送金相手を選択してください</option>
          {accounts
            .filter(a => a.id !== myUserId)
            .map(a => (
              <option key={a.id} value={a.id}>{a.username}</option>
            ))}
        </select>
        {errors.receiver && (
          <span className={styles.fieldError} role="alert">{errors.receiver}</span>
        )}
      </div>

      {/* 金額 */}
      <div className={styles.field}>
        <label className={styles.label} htmlFor="amount">金額（pt）</label>
        <input
          id="amount"
          type="text"
          inputMode="numeric"
          className={`${styles.input} ${
            errors.amount || isAmountInvalid ? styles['input--error'] :
            isAmountValid && !isOverBalance  ? styles['input--valid'] : ''
          }`}
          value={amount}
          onChange={e => handleAmountChange(e.target.value)}
          placeholder="例: 1000"
          disabled={isLoading}
        />
        {myBalance !== undefined && (
          <span className={styles.hint}>
            現在の残高: {myBalance.toLocaleString()} pt
          </span>
        )}
        {errors.amount && (
          <span className={styles.fieldError} role="alert">{errors.amount}</span>
        )}
      </div>

      <button type="submit" className={styles.button} disabled={isLoading}>
        {isLoading ? '送金中...' : '送金する'}
      </button>

      {/* 送金成功メッセージ */}
      {result.type === 'success' && (
        <div className={`${styles.alert} ${styles['alert--success']}`} role="status">
          <span className={styles.alertIcon}>✓</span>
          <span>{result.message}</span>
        </div>
      )}

      {/* API エラーメッセージ */}
      {result.type === 'error' && (
        <div className={`${styles.alert} ${styles['alert--error']}`} role="alert">
          <span className={styles.alertIcon}>!</span>
          <span>{result.message}</span>
        </div>
      )}
    </form>
  )
}
