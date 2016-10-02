require 'api_constraints'

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  
  scope :sessions do
    post 'verify',  to: 'sessions#verify'
    post 'login',   to: 'sessions#login'
    post 'logout',  to: 'sessions#logout'
  end
  
  namespace :api, defaults: { format: :json } do
    scope module: :v1,
              constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, only: [:create, :show, :update] do
        collection do
          get 'strangers', to: 'users#strangers'
          get 'friends', to: 'users#friends'
          get 'chats', to: 'users#chats'
          get 'inviters', to: 'users#inviters'
        end
      end
      resources :chats, only: [:index]
      resources :messages, only: [:create, :index]
    end
  end
end
