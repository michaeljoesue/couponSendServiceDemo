# Api::TransactionLogsController
#
# 送金の取引履歴を返すコントローラー。
# account_id パラメータを指定すると、そのアカウントが送信または受信した
# 履歴のみに絞り込む（フロントエンドのユーザー個別履歴表示に使用）。
#
# エンドポイント:
#   GET /api/transaction_logs                        - 全履歴
#   GET /api/transaction_logs?account_id=<uuid>      - 特定アカウントの送受信履歴
class Api::TransactionLogsController < ApplicationController
  def index
    # account_id が指定されている場合はそのアカウントに関連する履歴のみ返す
    logs = if params[:account_id].present?
      TransactionLog.for_account(params[:account_id])
    else
      TransactionLog.all
    end

    # .recent スコープで新しい順に並べる
    render json: logs.recent.map { |log| transaction_log_json(log) }
  end

  private

  def transaction_log_json(log)
    {
      id:               log.id,
      sender_id:        log.sender_id,
      receiver_id:      log.receiver_id,
      amount:           log.amount,
      status:           log.status,
      transaction_date: log.transaction_date
    }
  end
end
