class Api::V1::BaseController < ActionController::API
  before_action :doorkeeper_authorize!

  private


  def current_user
    @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id]) if doorkeeper_token
  end

  def current_application
    doorkeeper_token.application if doorkeeper_token&.application_id
  end
end