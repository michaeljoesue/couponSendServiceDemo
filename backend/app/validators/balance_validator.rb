# BalanceValidator
#
# 残高操作に関するパラメータを検証するクラス。
# コントローラーから直接呼び出し、バリデーションエラー時は
# ValidationError を raise することで ApplicationController の
# rescue_from に処理を委譲する。
class BalanceValidator
  class ValidationError < StandardError; end

  # 金額が 0 以上の数値であることを確認する
  # 送金では MoneyTransferService 側で追加チェックを行うが、
  # 残高の直接更新（PATCH /api/balances/:id）ではここのみで検証する
  def self.validate_amount(amount)
    unless amount.is_a?(Numeric) && amount >= 0
      raise ValidationError, "Invalid amount"
    end
  end

  # アカウントが存在することを確認する
  def self.validate_account_exists(account)
    unless account
      raise ValidationError, "Account not found"
    end
  end
end
