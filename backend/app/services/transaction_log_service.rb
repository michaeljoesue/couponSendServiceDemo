# TransactionLogService
#
# 送金の取引記録を transaction_logs テーブルに保存するサービスクラス。
# MoneyTransferService から呼び出され、成功・失敗のどちらも記録する。
#
# status の値:
#   'success' - 送金が正常に完了した
#   'failed'  - 残高不足などで送金が失敗した
class TransactionLogService
  def initialize(sender_id, receiver_id, amount, status)
    @sender_id   = sender_id
    @receiver_id = receiver_id
    @amount      = amount
    @status      = status
  end

  def call
    TransactionLog.create!(
      sender_id:        @sender_id,
      receiver_id:      @receiver_id,
      amount:           @amount,
      transaction_date: Time.current,
      status:           @status
    )
  end
end
