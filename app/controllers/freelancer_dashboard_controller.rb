class FreelancerDashboardController < ApplicationController
  # before_action :require_login

  def home
    # Projects already bid on or assigned via contract
    bid_project_ids = current_user.bids.pluck(:project_id)
    contract_project_ids = current_user.freelancer_contracts.pluck(:project_id)

    # Available projects: not already bid on or contracted, and not expired
    @available_projects = Project.where.not(id: bid_project_ids + contract_project_ids)
                                 .where("deadline >= ?", Date.today)

    # Contracts where user is freelancer
    @contracts = current_user.freelancer_contracts.includes(:project, :client)
  end

  def chat
    @project = Project.find(params[:project_id])
    @client = User.find(params[:client_id])

    @messages = Message.where(project: @project)
                       .where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
                              @client.id, current_user.id, current_user.id, @client.id)
                       .order(:created_at)

    @new_message = Message.new
  end
end
