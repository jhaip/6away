Tutorial::Application.routes.draw do
  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"

  root :to => 'users#index'

  resources :user_sessions
  resources :users do
    member do
      get :activate
    end
  end
  resources :password_resets

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

end
