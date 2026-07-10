class CreateTransactionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :transaction_logs do |t|
      t.string :sender_id, null: false
      t.string :receiver_id, null: false
      t.integer :amount, null: false
      t.datetime :transaction_date, null: false
      t.string :status, null: false
      t.timestamps
    end

    add_foreign_key :transaction_logs, :accounts, column: :sender_id
    add_foreign_key :transaction_logs, :accounts, column: :receiver_id
  end
end
