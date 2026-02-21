Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'api/users/omniauth_callbacks'
  }

  if Rails.env.development?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :auth do
      get 'login', to: 'login#index'
      get 'token', to: 'token#show'
      delete 'logout', to: 'logout#destroy'
    end
    resources :active_users, only: %i[index]
    resources :users, only: %i[index show] do
      resource :relationship, only: %i[create destroy]
      resources :posts, only: %i[index], controller: 'users/posts'
    end
    resource :me, only: %i[show update], controller: :me
    resources :notifications, only: %i[index] do
      collection do
        resource :unread_count, only: %i[show], module: :notifications, controller: :unread_counts
        post :read_all, to: 'notifications/read_all#create'
      end
    end
    resources :posts, only: %i[index show create update destroy] do
      resource :like, only: %i[create destroy], module: :posts
      resources :comments, only: %i[create destroy], module: :posts
    end
  end
end
