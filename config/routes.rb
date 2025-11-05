Rails.application.routes.draw do
  devise_for :users
  root to: 'posts#index'
  resource :profile

  namespace :api, defaults: { format: 'json'} do
    resource :avatar, only: %i(update)
  end
end
