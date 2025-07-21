class FreelancerDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project_and_client, only: [:chat]

  def home
    bid_ids       = current_user.bids.select(:project_id)
    contract_ids  = current_user.contracts_as_freelancer.select(:project_id)
    accepted_ids  = Bid.accepted.select(:project_id).distinct

    base_projects = Project.where.not(id: bid_ids)
                           .where.not(id: contract_ids)
                           .where.not(id: accepted_ids)
                           .where("deadline >= ?", Date.today)

    @skills = Skill.all
    @available_projects = if params[:skill_id].present?
      base_projects.joins(:skills).where(skills: { id: params[:skill_id] }).distinct
    else
      base_projects
    end

    @contracts = current_user.contracts_as_freelancer.includes(:project, :client)
    @bid       = Bid.new
  end

  def add_skill
    skill_id = params[:skill_id].to_i

    if skill_id.zero?
      flash[:alert] = "Please select a valid skill."
    elsif current_user.skills.exists?(id: skill_id)
      flash[:alert] = "Skill already exists in your profile."
    else
      current_user.skill_assignments.create(skill_id: skill_id)
      flash[:notice] = "Skill added successfully!"
    end

    redirect_to freelancer_dashboard_path(anchor: 'profile')
  end

  def create_custom_skill
    skill_name = params[:new_skill_name].to_s.strip.downcase

    if skill_name.blank?
      flash[:alert] = "Skill name cannot be blank."
    else
      existing_skill = Skill.find_by("LOWER(skill_name) = ?", skill_name)

      if existing_skill
        if current_user.skills.exists?(id: existing_skill.id)
          flash[:alert] = "Skill '#{existing_skill.skill_name}' already exists in your profile."
        else
          current_user.skill_assignments.create(skill: existing_skill)
          flash[:notice] = "Skill '#{existing_skill.skill_name}' added to your profile."
        end
      else
        new_skill = Skill.create(skill_name: skill_name.titleize)
        current_user.skill_assignments.create(skill: new_skill)
        flash[:notice] = "Custom skill '#{new_skill.skill_name}' added to your profile."
      end
    end

    redirect_to freelancer_dashboard_path(anchor: 'profile')
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

    def update_availability
    if current_user.update(availability_params)
      flash[:notice] = "Availability updated."
    else
      flash[:alert] = "Could not update availability."
    end
    redirect_back fallback_location: freelancer_dashboard_path
  end

  private

  def availability_params
    params.require(:user).permit(:available_for_work, :busy_until)
  end

  def set_project_and_client
    @project = Project.find_by(id: params[:project_id])
    @client  = User.find_by(id: params[:client_id])

    unless @project && @client
      redirect_to freelancer_dashboard_path, alert: "Chat not available."
    end
  end
end
