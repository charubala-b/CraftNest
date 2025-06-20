Rails.application.routes.draw do
  # Root path shows login page
  root "users#login"

  # User Authentication
  get "register", to: "users#new"
  post "register", to: "users#create"
  
  get "login", to: "users#login"
  post "login", to: "users#login_user"
  delete "logout", to: "users#logout"

  # Dashboard
  get "/dashboard", to: "dashboard#home"

  # Messages
  get "/messages", to: "dashboard#messages"
  get "/messages/:id", to: "dashboard#chat", as: "chat"

  # Profile
  get "/profile", to: "dashboard#profile"
  patch "/profile/update", to: "dashboard#update_profile"
  get "/profile/change_password", to: "dashboard#change_password"
  patch "/profile/update_password", to: "dashboard#update_password"

  # Nested routes for project -> bids
  resources :projects do
    resources :bids
    resources :comments,only: [:create, :destroy]
  end
   resources :projects
  # Standalone resources
  resources :contracts, only: [:update]
  resources :reviews, only: [:new, :create]
  resources :messages, only: [:create, :update]
  resources :comments, only: [:create, :update, :destroy]

  # Custom action to accept a bid
  post '/bids/:id/accept', to: 'bids#accept', as: 'accept_bid'
end
