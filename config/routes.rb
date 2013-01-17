Tutorial::Application.routes.draw do
  root :to => 'users#index'

  resources :user_sessions
  resources :users do
    member do
      get :activate
    end
  end

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

end
