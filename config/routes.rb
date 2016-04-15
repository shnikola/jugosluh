Rails.application.routes.draw do

  devise_for :users

  root 'home#index'

  resources :albums, only: [:index, :show] do
    get :random, on: :collection
    get :random_showcase, on: :collection
    get :tracks, on: :member
  end

  resources :users, only: [:show]
  resources :user_ratings, only: [:create, :edit, :update, :destroy]
  resources :user_lists, only: [:index, :show, :create, :destroy]
  resources :user_list_albums, only: [:new, :create, :destroy]
  resources :album_issues, only: [:index, :new, :create]
  
  resource :settings, only: [:show, :update]
  
  namespace :api do
    resources :albums, only: [:index]
    resources :user_ratings, only: [:index]
  end
end
