# ApplicationController
#
# 全APIコントローラーの基底クラス。
# アプリケーション全体で共通するエラーハンドリングをここに集約することで、
# 各コントローラーに rescue ブロックを書く必要をなくす。
#
# rescue_from の優先順位:
#   同一エラークラスが複数 rescue_from に該当する場合、最後に定義されたものが優先される。
#   継承関係があるエラー（例: InsufficientBalanceError < TransferError）は
#   より具体的なクラスを先に定義すること。
class ApplicationController < ActionController::API
  # MoneyTransferService が定義するビジネスロジック例外
  rescue_from MoneyTransferService::AccountNotFoundError,     with: :render_not_found
  rescue_from MoneyTransferService::InvalidTransferError,     with: :render_bad_request
  rescue_from MoneyTransferService::InsufficientBalanceError, with: :render_bad_request
  rescue_from MoneyTransferService::TransferError,            with: :render_internal_server_error

  # ActiveRecord によるレコード未検出 (find_by! 使用時)
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  # BalanceValidator によるパラメータ検証エラー
  rescue_from BalanceValidator::ValidationError, with: :render_bad_request

  private

  def render_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_bad_request(error)
    render json: { error: error.message }, status: :bad_request
  end

  def render_internal_server_error(error)
    render json: { error: error.message }, status: :internal_server_error
  end
end
