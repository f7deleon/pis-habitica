# frozen_string_literal: true

Rails.application.routes.draw do
  # - FOR DEVELOPMENT ONLY
  get '/killme', to: 'users#killme'

  post 'user_token' => 'user_token#create'
  namespace :me do
    get '', to: 'users#home'
    get 'habits', to: 'habits#index'
    resources :notifications
    resources :characters
    resources :requests
    resources :friends, controller: 'friends'
    resources :groups do
      member do
        get 'habits', to: 'groups#habits'
        post 'members', to: 'groups#update_members'
      end
    end
    post 'requests/:id', to: 'requests#add_friend'
  end
  resources :types
  resources :characters
  resources :habits, except: :index do
    member do
      post 'fulfill', to: 'habits#fulfill'
      delete 'fulfill', to: 'habits#undo_habit'
    end
  end
  resources :users do
    resources :friends, only: %i[index]
    member do
      get 'habits', to: 'users#index_habits'
    end
    resources :groups, only: %i[show index] do
      member do
        get 'habits', to: 'groups#habits'
        get 'habits/:habit', to: 'groups#habit'
      end
    end
  end

  resources :groups do
    member do
      post 'requests', to: 'request_group#send_request'
      get 'requests', to: 'request_group#requests'
    end
  end
  # - FOR DEVELOPMENT ONLY
  get '/killme', to: 'users#killme'
  get '/groups', to: 'groups#find_group'
  # For details on the DSL available wihthin this file, see http://guides.rubyonrails.org/routing.htm
end
