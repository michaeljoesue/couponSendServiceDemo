class CreateBalances < ActiveRecord::Migration[7.1]
  def change
    create_table :balances, id: false do |t|
      t.string :account_id, null: false, primary_key: true
      t.integer :value, null: false
      t.timestamps
    end
    add_foreign_key :balances, :accounts, column: :account_id
  end
end
