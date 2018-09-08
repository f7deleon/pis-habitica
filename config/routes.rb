# frozen_string_literal: true

Rails.application.routes.draw do
  resources :groups
  resources :types
  resources :users
  resources :habits

  namespace :me do
    resources :characters

    resources :habits do
      collection do
        post 'fulfill', to: 'habits#fulfill_habit'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.htm
end
