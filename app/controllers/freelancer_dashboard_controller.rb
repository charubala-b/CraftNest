class FreelancerDashboardController < ApplicationController
  def home
    bid_project_ids = current_user.bids.pluck(:project_id)
    contract_project_ids = current_user.freelancer_contracts.pluck(:project_id)

    accepted_project_ids = Bid.where(accepted: true).pluck(:project_id).uniq

    base_projects = Project.where.not(id: bid_project_ids + contract_project_ids + accepted_project_ids)
                           .where("deadline > ?", Date.today)

    @skills = Skill.all

    if params[:skill_id].present?
      @available_projects = base_projects.joins(:skills).where(skills: { id: params[:skill_id] }).distinct
    else
      @available_projects = base_projects
    end

    @contracts = current_user.freelancer_contracts.includes(:project, :client)

    @bid = Bid.new
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
