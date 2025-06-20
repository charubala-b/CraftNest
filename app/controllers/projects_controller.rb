class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :require_client

  def index
    @projects = current_user.projects
  end

  def show
    # @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  def destroy
  @project = current_user.projects.find_by(id: params[:id])
  if @project
    @project.destroy
    redirect_to dashboard_path
  else
    redirect_to dashboard_path, alert: "Project not found."
  end
end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :budget, :deadline)
  end

  def require_client
    redirect_to root_path unless current_user&.client?
  end
end
