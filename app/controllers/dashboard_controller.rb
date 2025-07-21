class DashboardController < ApplicationController
  before_action :authenticate_user!

  def home
    
    completed_project_ids = Contract.where(status: :completed, client_id: current_user.id).pluck(:project_id)

    @active_projects = current_user.projects.where.not(id: completed_project_ids).includes(:bids, :comments)
    @completed_projects = current_user.projects.where(id: completed_project_ids)

    @contracts = Contract.includes(:project, :freelancer).where(client_id: current_user.id)

    @messages = Message
                  .where("sender_id = :id OR receiver_id = :id", id: current_user.id)
                  .includes(:project, :sender, :receiver)
                  .order(created_at: :desc)
    
  end

  def chat
    @freelancer = User.find_by(id: params[:freelancer_id])
    @project = Project.find_by(id: params[:project_id])

    unless @freelancer && @project
      redirect_to dashboard_path, alert: "Chat participant or project not found." and return
    end

    @messages = Message.where(project_id: @project.id)
                       .where(sender_id: current_user.id, receiver_id: @freelancer.id)
                       .or(
                         Message.where(project_id: @project.id, sender_id: @freelancer.id, receiver_id: current_user.id)
                       ).order(:created_at)

    @new_message = Message.new
  end

end
