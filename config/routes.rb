# Rails.application.routes.draw do
  # get "dashboard/home"
#   get "users/new"
#   root "users#login"

#   get "register", to: "users#new"
#   post "register", to: "users#create"

#   get "login", to: "users#login"
#   post "login", to: "users#login_user"
#   delete "logout", to: "users#logout"
# end

Rails.application.routes.draw do
  # Root path shows login page
  root "users#login"

  # User Authentication
  get "register", to: "users#new"
  post "register", to: "users#create"
  
  get "login", to: "users#login"
  post "login", to: "users#login_user"
  delete "logout", to: "users#logout"

  # Dashboard (protected - ensure controller uses before_action to check login)
  get "/dashboard", to: "dashboard#home"

  # Messages - direct message style
  get "/messages", to: "dashboard#messages"
  get "/messages/:id", to: "dashboard#chat", as: "chat"

  # Profile management
  get "/profile", to: "dashboard#profile"
  patch "/profile/update", to: "dashboard#update_profile"
  get "/profile/change_password", to: "dashboard#change_password"
  patch "/profile/update_password", to: "dashboard#update_password"
end

