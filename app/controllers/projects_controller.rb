class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]
  before_action :require_client
  before_action :set_skills, only: [ :new, :edit, :create, :update ]
  before_action :authenticate_user!


  def index
    @projects = current_user.projects
  end

  def show; end

  def new
    @project = Project.new
  end

def create
  @project = current_user.projects.build(project_params.except(:skill_ids, :new_skills))

  if @project.budget.present? && @project.budget.to_f < 0
    flash.now[:alert] = "Budget cannot be negative."
    render :new and return
  end

  if @project.save
    # ✅ Fix here
    new_skill_ids = process_new_skills(params[:new_skills])
    all_skill_ids = Array(params[:project][:skill_ids]).map(&:to_i) + new_skill_ids
    assign_skills(@project, all_skill_ids.uniq)
    redirect_to dashboard_path, notice: "Successfully created a project"
  else
    render :new
  end
end


  def edit; end

  def update
    if project_params[:budget].to_f < 0
      flash.now[:alert] = "Budget cannot be negative."
      render :edit and return
    end

    if @project.update(project_params.except(:skill_ids, :new_skills))
      new_skill_ids = process_new_skills(params[:new_skills])
      all_skill_ids = Array(params[:project][:skill_ids]).map(&:to_i) + new_skill_ids
      assign_skills(@project, all_skill_ids.uniq)
      redirect_to dashboard_path, notice: "Project updated successfully."
    else
      flash.now[:alert] = "Failed to update project."
      render :edit
    end
  end

  def destroy
    @project = current_user.projects.find_by(id: params[:id])
    if @project
      @project.destroy
      redirect_to dashboard_path, notice: "Project deleted"
    else
      redirect_to dashboard_path, alert: "Project not found."
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def set_skills
    @skills = Skill.all
  end

  def project_params
    params.require(:project).permit(
      :title, :description, :budget, :deadline, :new_skills, skill_ids: []
    )
  end

  def require_client
    redirect_to root_path unless current_user&.client?
  end

  def assign_skills(project, skill_ids)
    project.skill_assignments.destroy_all
    skill_ids.each do |skill_id|
      project.skill_assignments.create(skill_id: skill_id)
    end
  end

  def process_new_skills(raw_new_skills)
    raw_new_skills.to_s.split(",").map(&:strip).reject(&:blank?).map do |skill_name|
      Skill.find_or_create_by(skill_name: skill_name.downcase).id
    end
  end
end
