class DashboardController < ApplicationController
  def home
    @current_user = User.find(session[:user_id])

    auto_complete_contracts

    @active_projects = @current_user.projects.where("deadline >= ?", Date.today)
    @completed_projects = @current_user.projects.where("deadline < ?", Date.today)

    @contracts = Contract.where(client_id: @current_user.id).includes(:project, :freelancer)

    @messages = Message.where("sender_id = ? OR receiver_id = ?", @current_user.id, @current_user.id)
  end

  def chat
  Rails.logger.debug "PARAMS: #{params.inspect}"

  @current_user = User.find_by(id: session[:user_id])
  @freelancer = User.find_by(id: params[:freelancer_id])
  @project = Project.find_by(id: params[:project_id])

  @messages = Message.where(project_id: @project.id)
                     .where(sender_id: @current_user.id, receiver_id: @freelancer.id)
                     .or(
                       Message.where(project_id: @project.id, sender_id: @freelancer.id, receiver_id: @current_user.id)
                     ).order(:created_at)

  @new_message = Message.new
end

  private

  def auto_complete_contracts
    Contract.joins(:project)
            .where(status: :inprogress)
            .where("end_date < ?", Date.today)
            .find_each do |contract|
      contract.update(status: :completed)
    end
  end
end
