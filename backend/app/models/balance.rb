# Balance モデル
#
# アカウントの残高を保持するモデル。
# primary_key は account_id（accounts テーブルへの外部キー）であり、
# 1アカウントにつき1レコードのみ存在する。
#
# 【重要】
# check_account_id バリデーション（CheckAccountIdLogic）は変更禁止。
# 特定アカウント（Bob: ab29face-...）の残高を直接更新できないようにする
# ガード処理が含まれているため、ロジックを削除・変更しないこと。
class Balance < ApplicationRecord
  belongs_to :account

  # 残高が負にならないことを保証する
  validates :value, numericality: { greater_than_or_equal_to: 0 }

  # DO NOT MODIFY THIS.
  include CheckAccountIdLogic

  validate :check_account_id, on: :update
end
