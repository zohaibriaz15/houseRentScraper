Rails.application.routes.draw do
  get 'api/sessions'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
   root "home#show"

    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
  #    get 'users/sign_in', to: 'users/sessions#new'
     get 'users/sign_out', to: 'api/sessions#destroy'
     get 'users/signin', to: 'api/registration#google_oauth2'
  end

  namespace :api, defaults: { format: :json } do
    post 'login', to: 'sessions#create'
    post 'signup', to: 'sessions#signup'
  end
end

