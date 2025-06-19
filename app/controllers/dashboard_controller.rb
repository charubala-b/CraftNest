class DashboardController < ApplicationController
  # before_action :set_current_user

  def home
    @current_user = User.find(session[:user_id])
    @projects = @current_user.projects.includes(:bids)
    @contracts = @current_user.contracts_as_client.includes(:project, :freelancer)
    @messages = Message.where("sender_id = ? OR receiver_id = ?", @current_user.id, @current_user.id)
  end

end
