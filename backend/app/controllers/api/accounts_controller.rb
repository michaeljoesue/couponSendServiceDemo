# Api::AccountsController
#
# ユーザーアカウント情報を提供するコントローラー。
# 残高情報は balances テーブルから includes で事前ロードし、N+1クエリを防ぐ。
#
# エンドポイント:
#   GET /api/accounts       - 全ユーザー一覧（フロントエンドのユーザーリスト表示に使用）
#   GET /api/accounts/:id   - 特定ユーザーの詳細（ログインユーザー情報取得に使用）
class Api::AccountsController < ApplicationController
  before_action :set_account, only: [:show]

  # 全アカウントと残高を返す
  def index
    accounts = Account.includes(:balance).all
    render json: accounts.map { |a| account_json(a, a.balance) }
  end

  # 特定アカウントの詳細を返す
  # sender_id フィールドをレスポンスに含めるのは、送金フォームの初期化に使うため
  def show
    render json: account_json(@account, @account.balance).merge(sender_id: @account.id)
  end

  private

  # find_by! を使うことで、未存在の場合は ActiveRecord::RecordNotFound を発生させ
  # ApplicationController の rescue_from に処理を委譲する
  def set_account
    @account = Account.includes(:balance).find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ActiveRecord::RecordNotFound, "Account not found"
  end

  def account_json(account, balance)
    { id: account.id, username: account.username, balance: balance.value }
  end
end
