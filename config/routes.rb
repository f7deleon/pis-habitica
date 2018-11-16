# frozen_string_literal: true

Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  get '/groups', to: 'groups#find_group'
  namespace :me do
    get '', to: 'users#home'
    get 'habits', to: 'habits#index'
    resources :notifications
    resources :characters
    resources :requests do 
      member do 
        post '', to: 'requests#add_friend'
      end  
    end
    resources :friends, controller: 'friends'
    resources :groups, only: %i[index destroy]
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
    resources :groups, only: %i[index]
  end

  resources :groups do
    member do
      post 'requests', to: 'request_group#send_request'
      get 'requests', to: 'request_group#requests'
      post 'requests/:request', to: 'request_group#add_member'
      delete 'requests/:request', to: 'request_group#not_add_member'
      get 'habits', to: 'groups#habits'
      get 'members', to: 'groups#members'
      post 'members', to: 'groups#update_members'
    end
  end

end
