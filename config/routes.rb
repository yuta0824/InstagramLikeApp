require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  namespace :api, defaults: { format: 'json' } do
    resources :accounts, only: %i[index] do
      resource  :relationship, only: [:create, :destroy]
    end
    namespace :me do
      resource :avatar, only: %i[update]
    end
    resources :posts, only: [] do
      resource :like, only: %i[create destroy], module: :posts
      resource :comment, only: %i[create], module: :posts
    end
  end
end
