class ApplicationController < ActionController::Base
  helper_method :current_user_api

  private

  def current_user_api
    @current_user ||= User.find_by(id: doorkeeper_token&.resource_owner_id)
  end
end
