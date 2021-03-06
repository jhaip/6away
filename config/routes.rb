Tutorial::Application.routes.draw do
  get "graph/index"

  get "main/index"

  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"

  root :to => 'main#index'

  resources :user_sessions
  resources :users do
    member do
      get :activate
    end
  end
  resources :password_resets

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  
  match 'graph' => 'graph#index', :as => :graph
  match 'datapull' => 'graph#datapull', :as => :datapull
  match 'datapush' => 'graph#datapush', :via => :post, :as => :datapush
  match 'datadelete' => 'graph#datadelete', :via => :delete, :as => :datadelete

  match 'profile' => 'graph#profile', :via => :get, :as => :profile
  match 'profile' => 'graph#profile_push', :via => :post, :as => :profile_push

  match 'userpull' => 'graph#userpull', :as => :userpull
  match 'creategraph' => 'graph#create', :as => :creategraph

end
