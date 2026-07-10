# Account モデル
#
# ユーザーアカウントを表す。1アカウントにつき1つの残高（Balance）を持つ。
# アカウントIDは UUID 文字列（シードデータで事前定義）。
#
# アソシエーション:
#   balance              - このアカウントの残高（has_one）
#   sent_transactions    - このアカウントが送金した取引履歴
#   received_transactions - このアカウントが受け取った取引履歴
class Account < ApplicationRecord
  validates :username, presence: true

  has_one  :balance,               dependent: :destroy
  has_many :sent_transactions,     class_name: 'TransactionLog', foreign_key: 'sender_id',   dependent: :destroy
  has_many :received_transactions, class_name: 'TransactionLog', foreign_key: 'receiver_id', dependent: :destroy
end
