Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users
  root to: 'posts#index'
  resource :profile

  namespace :api, defaults: { format: 'json'} do
    resource :avatar, only: %i(update)
  end
end
