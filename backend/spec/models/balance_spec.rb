require 'rails_helper'

RSpec.describe Balance, type: :model do
  describe 'associations' do
    let(:account) { Account.create!(id: "906ae09d-3701-4f78-8fe1-9be221547148", username: "John") }

    it 'belongs_to :account' do
      balance = Balance.create!(account: account, value: 50000)
      expect(balance.account).to eq(account)
    end
  end

  describe 'validations' do
    let(:account) { Account.create!(id: "906ae09d-3701-4f78-8fe1-9be221547148", username: "John") }

    context 'value validation' do
      it 'is valid with valid attributes' do
        balance = Balance.new(account: account, value: 50000)
        expect(balance).to be_valid
      end

      it 'is valid with zero value' do
        balance = Balance.new(account: account, value: 0)
        expect(balance).to be_valid
      end
    end

    context 'check_account_id validation on update' do
      it 'allows update for normal accounts' do
        balance = Balance.create!(account: account, value: 50000)
        balance.value = 45000
        expect(balance).to be_valid
        expect { balance.save! }.not_to raise_error
      end
    end
  end
end
