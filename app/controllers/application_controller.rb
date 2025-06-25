class ApplicationController < ActionController::Base
  # Makes current_user accessible in views
  helper_method :current_user

  # Define your custom current_user logic (if not using Devise helpers)
  # def current_user
  #   @current_user ||= User.find_by(id: session[:user_id])
  # end

  # Permit additional parameters for Devise sign-up (and potentially update)
  before_action :configure_permitted_parameters, if: :devise_controller?

  # After login, redirect based on role
  def after_sign_in_path_for(resource)
    if resource.freelancer?
      freelancer_dashboard_path
    else
      dashboard_path
    end
  end

  # After sign-up, use same logic as sign-in
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  protected

  # Extend Devise's parameter sanitizer
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role, :new_skills, skill_ids: []])
  end
end
