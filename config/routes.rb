Chicktech::Application.routes.draw do
  resources :events
  devise_for :users
  resources :users, :only => [:show, :index]
  root :to => "static_pages#index"
end
