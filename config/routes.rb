require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'api/users/omniauth_callbacks'
  }

  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :users do
      get '/auth', to: 'auth#index'
      get 'token_exchange', to: 'token_exchanges#show'
      delete 'logout', to: 'logout#destroy'
    end
    resources :accounts, only: %i[index] do
      resource  :relationship, only: %i[create destroy]
    end
    resource :me, only: %i[show update], controller: :me
    resources :posts, only: %i[show create update destroy] do
      resource :like, only: %i[create destroy], module: :posts
      resource :comment, only: %i[create], module: :posts
    end
  end
end
