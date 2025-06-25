class FreelancerDashboardController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_project_and_client, only: [:chat]

  def home
    bid_ids       = current_user.bids.select(:project_id)
    contract_ids  = current_user.contracts_as_freelancer.select(:project_id)
    accepted_ids  = Bid.accepted.select(:project_id).distinct

    base_projects = Project.where.not(id: bid_ids)
                           .where.not(id: contract_ids)
                           .where.not(id: accepted_ids)
                           .where("deadline > ?", Date.today)

    @skills = Skill.all

    @available_projects = if params[:skill_id].present?
      base_projects.joins(:skills).where(skills: { id: params[:skill_id] }).distinct
    else
      base_projects
    end

    @contracts = current_user.contracts_as_freelancer.includes(:project, :client)
    @bid       = Bid.new
  end

  def chat
    @messages = Message.where(project: @project)
                       .where(
                         "(sender_id = :a AND receiver_id = :b) OR (sender_id = :b AND receiver_id = :a)",
                         a: @client.id, b: current_user.id
                       )
                       .order(:created_at)

    @new_message = Message.new
  end

  private

  def set_project_and_client
    @project = Project.find_by(id: params[:project_id])
    @client  = User.find_by(id: params[:client_id])

    unless @project && @client
      redirect_to freelancer_dashboard_path, alert: "Chat not available."
    end
  end
end
