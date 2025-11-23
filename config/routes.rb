Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # TODO: API Docs へ認証を掛けるか非本番のみで公開する
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users
  root to: 'posts#index'
  resources :posts, only: %i(index new create destroy) do
    resources :comments, only: %i(index)
  end
  resources :accounts, only: %i(show), param: :username, constraints: { username: /[a-zA-Z0-9_]+/ }

  namespace :api, defaults: { format: 'json' } do
    resources :accounts, only: %i[index]
    namespace :me do
      resource :avatar, only: %i[update]
    end
    resources :posts, only: [] do
      resource :like, only: %i[create destroy], module: :posts
      resource :comment, only: %i[create], module: :posts
    end
  end
end
