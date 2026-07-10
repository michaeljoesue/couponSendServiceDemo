require 'rails_helper'

RSpec.describe 'Api::Balances', type: :request do
  describe 'GET /api/balances/:id' do
    let!(:account) { Account.create!(id: "906ae09d-3701-4f78-8fe1-9be221547148", username: "John") }
    let!(:balance) { Balance.create!(account: account, value: 50000) }

    context 'when the account exists' do
      it 'returns the balance for the specified account' do
        get "/api/balances/#{account.id}", as: :json
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['account_id']).to eq(account.id)
        expect(json_response['balance']).to eq(balance.value)
      end
    end

    context 'when the account does not exist' do
      it 'returns a not found status' do
        get "/api/balances/non-existent-id", as: :json
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Account not found")
      end
    end
  end

  describe 'PATCH /api/balances/:id' do
    let!(:account) { Account.create!(id: "906ae09d-3701-4f78-8fe1-9be221547148", username: "John") }
    let!(:balance) { Balance.create!(account: account, value: 50000) }

    context 'with valid amount' do
      it 'updates the balance successfully' do
        patch "/api/balances/#{account.id}", params: { amount: 45000 }, as: :json
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Balance updated successfully")
        expect(json_response['account_id']).to eq(account.id)
        expect(json_response['new_balance']).to eq(45000)
        balance.reload
        expect(balance.value).to eq(45000)
      end
    end

    context 'with invalid amount (negative)' do
      it 'returns a bad request status' do
        patch "/api/balances/#{account.id}", params: { amount: -100 }, as: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Invalid amount")
      end
    end

    context 'with invalid amount (non-numeric)' do
      it 'returns a bad request status' do
        patch "/api/balances/#{account.id}", params: { amount: "invalid" }, as: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Invalid amount")
      end
    end

    context 'when the account does not exist' do
      it 'returns a not found status' do
        patch "/api/balances/non-existent-id", params: { amount: 10000 }, as: :json
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Account not found")
      end
    end
  end

  describe 'POST /api/balances' do
    let!(:sender) { Account.create!(id: "906ae09d-3701-4f78-8fe1-9be221547148", username: "John") }
    let!(:sender_balance) { Balance.create!(account: sender, value: 50000) }
    let!(:receiver) { Account.create!(id: "181cd98b-d1a8-46a3-bc77-a0ed4d40f702", username: "Ken") }
    let!(:receiver_balance) { Balance.create!(account: receiver, value: 12000) }

    context 'with valid transfer request' do
      it 'transfers money successfully' do
        post "/api/balances", params: {
          sender_id: sender.id,
          receiver_id: receiver.id,
          amount: 10000
        }, as: :json
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['sender_id']).to eq(sender.id)
        expect(json_response['username']).to eq(sender.username)
        expect(json_response['balance']).to eq(40000)

        sender_balance.reload
        receiver_balance.reload
        expect(sender_balance.value).to eq(40000)
        expect(receiver_balance.value).to eq(22000)

        # Check transaction log was created
        transaction_log = TransactionLog.last
        expect(transaction_log).to be_present
        expect(transaction_log.sender_id).to eq(sender.id)
        expect(transaction_log.receiver_id).to eq(receiver.id)
        expect(transaction_log.amount).to eq(10000)
        expect(transaction_log.status).to eq('success')
      end
    end

    context 'when sender account does not exist' do
      it 'returns a not found status' do
        post "/api/balances", params: {
          sender_id: 'non-existent-sender',
          receiver_id: receiver.id,
          amount: 10000
        }, as: :json
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Account not found")
      end
    end

    context 'when receiver account does not exist' do
      it 'returns a not found status' do
        post "/api/balances", params: {
          sender_id: sender.id,
          receiver_id: 'non-existent-receiver',
          amount: 10000
        }, as: :json
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Account not found")
      end
    end

    context 'when sender and receiver are the same' do
      it 'returns a bad request status' do
        post "/api/balances", params: {
          sender_id: sender.id,
          receiver_id: sender.id,
          amount: 10000
        }, as: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Cannot transfer to same account")
      end
    end

    context 'with invalid amount (zero or negative)' do
      it 'returns a bad request status for zero amount' do
        post "/api/balances", params: {
          sender_id: sender.id,
          receiver_id: receiver.id,
          amount: 0
        }, as: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Invalid amount")
      end

      it 'returns a bad request status for negative amount' do
        post "/api/balances", params: {
          sender_id: sender.id,
          receiver_id: receiver.id,
          amount: -1000
        }, as: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Invalid amount")
      end
    end

    context 'when sender has insufficient balance' do
      it 'returns a bad request status' do
        post "/api/balances", params: {
          sender_id: sender.id,
          receiver_id: receiver.id,
          amount: 60000
        }, as: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Insufficient balance")

        # Check transaction log was created with failed status
        transaction_log = TransactionLog.last
        expect(transaction_log).to be_present
        expect(transaction_log.status).to eq('failed')
      end
    end
  end
end
