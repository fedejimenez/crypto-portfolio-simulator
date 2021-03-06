require 'sidekiq/web'
Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Homepage
  root 'home#landing'
  get '/about' => 'home#about'
  get '/home' => 'home#home'
  get '/home/index' => 'home#index'
  get '/home/ranking' => 'home#ranking'

  # Suggestions / Comments
  get '/home/suggestions' => 'home#suggestions'
  post '/home/suggestions/users/:id/new' => 'comment#create'

  resources :comments, except: [:edit, :update, :destroy] do
    resources :comments, except: [:edit, :update, :destroy]
  end
  resources :users do
    resources :comments, except: [:edit, :update, :destroy]
  end

  # Likes for comments
  match 'like', to: 'likes#like', via: :post
  match 'dislike', to: 'likes#dislike', via: :delete

  # Follow users
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :relationships, only: [:create, :destroy]

  # Notifications
  resources :notifications do 
    collection do
      post :mark_as_read
    end
  end

  # User Settings
  resources :users , only: [:show] do 
      get '/settings' => 'users#settings'
  end

  # Lookup search
  get :lookup, controller: :home
  post '/lookup' => 'home#lookup'
  resources :searches

  # Signup. The first renders a form, the second receives the form and create a user in the database.
  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  # get '/users' => 'users#show'

  # these routes are for showing users a login form and log in / out.
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  # Routes for showing and editing users data
  resources :users

  # Gmail signup/login
  get "/auth/:provider/callback" => "sessions#create_from_omniauth"
  get 'auth/failure', to: redirect('/')
  get 'login', to: redirect('/auth/google_oauth2'), as: 'login_google'

  # Facebook signup/login
  get 'login', to: redirect('/auth/facebook'), as: 'login_facebook'

  # Portfolio and Movements
  resources :portfolios do
    resources :cryptos, except: [:index]
    resources :movements
  end
  resources :cryptos
  post 'portfolios/:id/cryptos/new' => 'cryptos#create'

  # Sidekiq
  mount Sidekiq::Web => '/sidekiq'

end