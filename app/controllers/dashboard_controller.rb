# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_client

  def home
    @user = current_user

    # Client-specific dashboard data
    @projects = @user.projects.includes(:bids, :contracts)
    @bids = Bid.where(project_id: @projects.pluck(:id)).includes(:user)
    @contracts = Contract.where(client_id: @user.id)
    @completed_contracts = @contracts.completed
    @freelancers_to_review = @completed_contracts.select do |contract|
      Review.where(project_id: contract.project_id, reviewer_id: @user.id).blank?
    end
  end

  private

  def require_client
    redirect_to root_path, alert: 'Access denied' unless current_user.client?
  end
end
