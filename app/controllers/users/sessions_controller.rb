# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  
  def after_sign_in_path_for(resource)
    resource.freelancer? ? freelancer_dashboard_path : client_dashboard_path
  end

  # Optional: Uncomment this if you ever want to permit extra sign-in params
  # protected
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
