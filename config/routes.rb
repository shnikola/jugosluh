Rails.application.routes.draw do
  
  devise_for :users
  
  root 'home#index'

  resources :albums, only: [:index, :show] do
    get :random, on: :collection
  end

  resources :users, only: [:show]
  resources :user_ratings, only: [:create, :edit, :update, :destroy]
end
