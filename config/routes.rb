# frozen_string_literal: true

Rails.application.routes.draw do
  resources :groups
  resources :types
  resources :characters
  resources :users do
    member do
      post 'add_character', to: 'users#add_character'
    end
  end
  resources :habits do
    collection do
      post 'fulfill', to: 'habits#fulfill_habit'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
