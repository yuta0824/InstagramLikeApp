Rails.application.routes.draw do
  # TODO: API Docs へ認証を掛けるか非本番のみで公開する
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users
  root to: 'posts#index'
  resources :posts
  resource :profile

  namespace :api, defaults: { format: 'json'} do
    resource :avatar, only: %i(update)
  end
end
