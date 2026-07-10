class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: :string do |t|
      t.string :username, null: false
      t.timestamps
    end
  end
end
