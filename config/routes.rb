require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # TODO: API Docs へ認証を掛けるか非本番のみで公開する
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

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
