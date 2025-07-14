class Api::V1::BaseController < ActionController::API
  # before_action :doorkeeper_authorize!
private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: doorkeeper_token&.resource_owner_id)
  end

  def current_application
    doorkeeper_token&.application
  end

  def authorize_client!
    unless current_user&.client?
      render json: { error: "Only clients can perform this action." }, status: :forbidden
    end
  end

  def authorize_freelancer!
    unless current_user&.freelancer?
      render json: { error: "Only freelancers can perform this action." }, status: :forbidden
    end
  end

  def authorize_client_user!
    authorize_client!
  end

  def authorize_access_to_contract!
    unless @contract.client_id == current_user&.id || @contract.freelancer_id == current_user&.id
      render json: { error: "You are not authorized to view this contract." }, status: :unauthorized
    end
  end

  def authorized_to_view_review?(project)
    if current_user&.client?
      project.client_id == current_user.id
    elsif current_user&.freelancer?
      Contract.exists?(project_id: project.id, freelancer_id: current_user.id)
    else
      false
    end
  end

  def authorized_to_create_review?(project)
    authorized_to_view_review?(project)
  end

end
