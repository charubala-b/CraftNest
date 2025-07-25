Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords" }
  devise_scope :user do
    get "/users/auth/:provider", to: "users/omniauth_callbacks#passthru", as: :user_omniauth_authorize
    get "/users/auth/:provider/callback", to: "users/omniauth_callbacks#google_oauth2", as: :user_omniauth_callback
  end


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


root to: redirect { |params, req|
  if req.env["warden"].authenticate?
    user = req.env["warden"].user
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
  get "freelancers/:id/analytics", to: "analytics#show", as: "freelancer_analytics"


  # Chat Routes
  get "chat/:freelancer_id/:project_id", to: "dashboard#chat", as: "chat_room"
  get "freelancer/chat/:client_id/:project_id", to: "freelancer_dashboard#chat", as: "freelancer_chat_room"
  resources :freelancer_dashboard, only: [ :home ] do
    collection do
      post :add_skill
      post :create_custom_skill
    end
  end


  # Projects and Nested Resources
  resources :projects do
    resources :bids, only: [ :create, :edit, :update, :destroy ]
    resources :comments, only: [ :create, :destroy ]
  end

  # Bids
  post "/bids/:id/accept", to: "bids#accept", as: "accept_bid"

  # Reviews
  resources :reviews, only: [ :new, :create ]

  # Messages
  resources :messages, only: [ :create, :update ]

  # Comments
  resources :comments, only: [ :create, :update, :destroy ]

  # Contracts
  resources :contracts, only: [ :update ]
# config/routes.rb
resources :skill_assignments, only: [ :create, :destroy ]
get "/test_google", to: redirect("/users/auth/google_oauth2")

# newly added
namespace :api do
  namespace :v1 do
    resources :projects do
      resources :bids, only: [ :index, :create ]
      resources :comments, only: [ :index, :create ]
    end

    resources :bids, only: [ :index, :update, :destroy, :show ] do
      post :accept, on: :member
    end
    get "contracts/completed", to: "contracts#completed"
    resources :contracts, only: [ :index, :show, :create, :update ]

    resources :reviews, only: [] do
      collection do
        get  ":project_id", to: "reviews#show",   as: :show
        post ":project_id", to: "reviews#create", as: :create
      end
    end # uses project_id & current_user context

    resources :comments, only: [ :update, :destroy, :show ]
  end
end
patch "freelancer/update_availability", to: "freelancer_dashboard#update_availability", as: :update_freelancer_availability
end
