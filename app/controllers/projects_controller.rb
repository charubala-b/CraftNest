class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :require_client
  before_action :set_skills, only: [:new, :edit, :create, :update]

  def index
    @projects = current_user.projects
  end

  def show; end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.build(project_params)

    if @project.budget.present? && @project.budget.to_i < 0
      flash.now[:alert] = "Budget cannot be negative."
      render :new and return
    end

    if @project.save
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

    if @project.update(project_params)
      redirect_to dashboard_path, notice: "Project updated successfully"
    else
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
    params.require(:project).permit(:title, :description, :budget, :deadline, skill_ids: [])
  end

  def require_client
    redirect_to root_path unless current_user&.client?
  end
end
