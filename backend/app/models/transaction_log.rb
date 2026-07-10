# TransactionLog モデル
#
# 送金の実行履歴を記録するモデル。
# 成功・失敗を問わず全ての送金試行が記録される。
#
# status の値:
#   'success' - 送金が完了した
#   'failed'  - 残高不足などで送金が失敗した
#
# スコープ:
#   for_account(id) - 送信または受信に関わった履歴を取得
#   recent          - 新しい順に並び替え
class TransactionLog < ApplicationRecord
  belongs_to :sender,   class_name: 'Account', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'Account', foreign_key: 'receiver_id'

  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[success failed] }

  # 特定アカウントに関連する全履歴（送信・受信どちらも）を返す
  scope :for_account, ->(account_id) {
    where(sender_id: account_id).or(where(receiver_id: account_id))
  }

  # 新しい取引順に並べる
  scope :recent, -> { order(transaction_date: :desc) }
end
