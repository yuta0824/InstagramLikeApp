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
    namespace :auth do
      get 'login', to: 'login#index'
      get 'token', to: 'token#show'
      delete 'logout', to: 'logout#destroy'
    end
    resources :users, only: %i[index] do
      resource :relationship, only: %i[create destroy]
    end
    resource :me, only: %i[show update], controller: :me
    resources :posts, only: %i[index show create update destroy] do
      resource :like, only: %i[create destroy], module: :posts
      resources :comments, only: %i[create destroy], module: :posts
    end
  end
end
