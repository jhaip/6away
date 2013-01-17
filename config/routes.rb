Tutorial::Application.routes.draw do
  root :to => 'users#index'

  resources :user_sessions
  resources :users

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destory', :as => :logout

end
