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

  namespace :api, defaults: { format: 'json'} do
    resource :avatar, only: %i(update)
    resources :users, only: %i(index)
    resources :posts, only: [] do
      resource :like, only: %i[create destroy]
      resource :comment, only: %i[create]
    end
  end
end
