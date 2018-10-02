# frozen_string_literal: true

Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  resources :groups
  resources :types
  resources :users
  resources :habits
  resources :characters
  namespace :me do
    get 'home', to: 'users#home'

    resources :characters
    resources :requests
    resources :friends, controller: 'friends'

    resources :habits do
      member do
        post 'fulfill', to: 'habits#fulfill'
      end
    end

    post 'requests/:id', to: 'requests#add_friend'
  end
  # For details on the DSL available wihthin this file, see http://guides.rubyonrails.org/routing.htm
end
