# Api::BalancesController
#
# 残高の参照・更新・送金処理を担うコントローラー。
# ビジネスロジックは MoneyTransferService に委譲しており、
# このコントローラーはリクエスト受付とレスポンス返却に専念する。
#
# エンドポイント:
#   GET    /api/balances/:id  - 特定アカウントの残高参照
#   PATCH  /api/balances/:id  - 残高を直接更新（管理用途）
#   POST   /api/balances      - ポイント送金の実行
class Api::BalancesController < ApplicationController
  before_action :set_account_and_balance, only: [:show, :update]

  # 残高を返す
  def show
    render json: { account_id: @account.id, balance: @balance.value }
  end

  # 残高を指定した金額に直接上書きする（管理・テスト用途を想定）
  # 通常の送金処理には POST /api/balances（create アクション）を使うこと
  def update
    amount = balance_params[:amount].to_i
    BalanceValidator.validate_amount(amount)
    @balance.update!(value: amount)
    render json: { message: "Balance updated successfully", account_id: @account.id, new_balance: @balance.value }
  end

  # 送金処理のエントリーポイント。
  # 実際のバリデーション・残高更新・ログ記録は MoneyTransferService が行う。
  # エラーは ApplicationController の rescue_from で一元的に処理される。
  def create
    result = MoneyTransferService.new(
      transfer_params[:sender_id],
      transfer_params[:receiver_id],
      transfer_params[:amount].to_i  # params は文字列で渡されるため整数に変換
    ).call
    render json: result
  end

  private

  def set_account_and_balance
    @account = Account.find_by!(id: params[:id])
    @balance = @account.balance
  rescue ActiveRecord::RecordNotFound
    raise ActiveRecord::RecordNotFound, "Account not found"
  end

  def balance_params
    params.permit(:amount)
  end

  def transfer_params
    params.permit(:sender_id, :receiver_id, :amount)
  end
end
