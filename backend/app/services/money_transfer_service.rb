# MoneyTransferService
#
# ポイント送金のビジネスロジックを担うサービスクラス。
# コントローラーから呼び出され、バリデーション・残高更新・ログ記録を一括で行う。
#
# 使い方:
#   result = MoneyTransferService.new(sender_id, receiver_id, amount).call
#   # => { sender_id:, username:, balance: } または例外を raise
#
# 例外の階層:
#   TransferError（基底）
#     ├─ AccountNotFoundError      アカウントが存在しない
#     ├─ InvalidTransferError      自己送金・無効な金額
#     └─ InsufficientBalanceError  残高不足
class MoneyTransferService
  class TransferError < StandardError; end
  class InsufficientBalanceError < TransferError; end
  class InvalidTransferError < TransferError; end
  class AccountNotFoundError < TransferError; end

  def initialize(sender_id, receiver_id, amount)
    @sender_id   = sender_id
    @receiver_id = receiver_id
    @amount      = amount
  end

  def call
    validate!
    execute_transfer
  end

  private

  attr_reader :sender_id, :receiver_id, :amount

  # DB アクセス前に行う入力値の検証。
  # 早期 raise することで不要なクエリを省く。
  def validate!
    raise AccountNotFoundError,  "Account not found"               unless sender && receiver
    raise InvalidTransferError,  "Cannot transfer to same account" if sender_id == receiver_id
    raise InvalidTransferError,  "Invalid amount"                  unless amount.is_a?(Integer) && amount > 0
  end

  # 送金処理全体のフロー。
  # 残高更新（transfer_balances）の後に成功ログを記録する。
  #
  # 【設計上の注意】
  # 成功ログの記録をトランザクション外に置いている理由:
  #   トランザクション内でログを作成すると、ログ作成の失敗が
  #   残高更新まで巻き戻す原因になる。ポイント移動の確定を
  #   ログ記録より優先するため、意図的にトランザクション外に出している。
  #   （サーバークラッシュ等でログが欠落するケースは残るが、本アプリの
  #   スコープでは許容範囲とする）
  def execute_transfer
    result = transfer_balances
    log_transaction('success')
    result
  rescue InsufficientBalanceError
    log_transaction('failed')
    raise
  rescue StandardError => e
    log_transaction('failed')
    raise TransferError, "Transfer failed: #{e.message}"
  end

  # 残高の増減をDBトランザクションで原子的に実行する。
  # どちらかの update! が失敗した場合、両方がロールバックされる。
  def transfer_balances
    ActiveRecord::Base.transaction do
      raise InsufficientBalanceError, "Insufficient balance" if sender_balance.value < amount

      sender_balance.update!(value: sender_balance.value - amount)
      receiver_balance.update!(value: receiver_balance.value + amount)

      { sender_id: sender.id, username: sender.username, balance: sender_balance.reload.value }
    end
  end

  def log_transaction(status)
    TransactionLogService.new(sender_id, receiver_id, amount, status).call
  end

  # メモ化により、同一リクエスト内での DB クエリを1回に抑える
  def sender
    @sender ||= Account.find_by(id: sender_id)
  end

  def receiver
    @receiver ||= Account.find_by(id: receiver_id)
  end

  def sender_balance
    @sender_balance ||= sender.balance
  end

  def receiver_balance
    @receiver_balance ||= receiver.balance
  end
end
