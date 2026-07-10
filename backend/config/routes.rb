Rails.application.routes.draw do
  namespace :api do
    resources :accounts, only: %i[show index]
    resources :balances, only: %i[show create update]
    resources :transaction_logs, only: %i[index]
  end

  get '/health_check', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, [{ status: 'OK' }.to_json]] }
end
