Rails.application.routes.draw do
  # Root path
  root "users#login"

  # Authentication
  get    "register",     to: "users#new"
  post   "register",     to: "users#create"
  get    "login",        to: "users#login"
  post   "login",        to: "users#login_user", as: "login_user"   # 🆕 Named route
  delete "logout",       to: "users#logout"

  # Client Dashboard
  get "client/dashboard", to: "dashboard#home", as: "client_dashboard"

  # Freelancer Dashboard
  get "freelancer/dashboard", to: "freelancer_dashboard#home", as: "freelancer_dashboard"
  get "freelancer/contracts", to: "freelancer_dashboard#contracts"
  get "freelancer/bids",      to: "freelancer_dashboard#bids"
  post "freelancer/bids/:project_id", to: "bids#create", as: "submit_bid"

  # Shared Dashboard
  get "/dashboard", to: "dashboard#home"

  # Chat Routes
  get 'chat/:freelancer_id/:project_id', to: 'dashboard#chat', as: 'chat_room'
  get 'freelancer/chat/:client_id/:project_id', to: 'freelancer_dashboard#chat', as: 'freelancer_chat_room'

  # Profile Management
  get   "/profile",                  to: "dashboard#profile"
  patch "/profile/update",          to: "dashboard#update_profile"
  get   "/profile/change_password", to: "dashboard#change_password"
  patch "/profile/update_password", to: "dashboard#update_password"

  # Projects and Nested Resources
  resources :projects do
    resources :bids, only: [:create, :edit, :update, :destroy]
    resources :comments, only: [:create, :destroy]
  end

  # Bids
  post '/bids/:id/accept', to: 'bids#accept', as: 'accept_bid'

  # Reviews
  resources :reviews, only: [:new, :create]

  # Messages
  resources :messages, only: [:create, :update]

  # Comments
  resources :comments, only: [:create, :update, :destroy]

  # Contracts
  resources :contracts, only: [:update]
end
