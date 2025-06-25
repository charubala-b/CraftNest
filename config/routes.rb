Rails.application.routes.draw do
  # Devise Authentication
  devise_for :users, controllers: { registrations: 'users/registrations' }


root to: redirect { |params, req|
  if req.env['warden'].authenticate?
    user = req.env['warden'].user
    user.freelancer? ? "/freelancer/dashboard" : "/client/dashboard"
  else
    "/users/sign_in"
  end
}


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
  resources :freelancer_dashboard, only: [:home] do
    collection do
      post :add_skill
      post :create_custom_skill
    end
  end


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
  # config/routes.rb
resources :skill_assignments, only: [:create, :destroy]

end
