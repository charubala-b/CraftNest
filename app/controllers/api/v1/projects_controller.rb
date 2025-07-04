class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_project, only: [:show, :update, :destroy]
  before_action :authorize_client_user!, only: [:create, :update, :destroy]

  # GET /api/v1/projects
  def index
    if current_user&.client?
      @projects = current_user.projects.includes(:skills)
    elsif current_user&.freelancer?
      @projects = Project.includes(:skills).all
    elsif current_application
      @projects = Project.includes(:skills).all
    else
      @projects = []
    end
    render :index
  end

  # GET /api/v1/projects/:id
  def show
    if current_user&.client? && @project.client_id != current_user.id
      render json: { error: "Unauthorized access." }, status: :unauthorized
    else
      render :show
    end
  end

  # POST /api/v1/projects
  def create
    @project = current_user.projects.build(project_params.except(:skill_ids, :new_skills))

    if @project.budget.present? && @project.budget.to_f < 0
      return render json: { error: "Budget cannot be negative." }, status: :unprocessable_entity
    end

    if @project.save
      new_skill_ids = process_new_skills(params[:new_skills])
      all_skill_ids = Array(params[:project][:skill_ids]).map(&:to_i) + new_skill_ids
      assign_skills(@project, all_skill_ids.uniq)
      render :show, status: :created
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:id
  def update
    if current_user&.id != @project.client_id
      return render json: { error: "Unauthorized action." }, status: :unauthorized
    end

    if project_params[:budget].to_f < 0
      return render json: { error: "Budget cannot be negative." }, status: :unprocessable_entity
    end

    if @project.update(project_params.except(:skill_ids, :new_skills))
      new_skill_ids = process_new_skills(params[:new_skills])
      all_skill_ids = Array(params[:project][:skill_ids]).map(&:to_i) + new_skill_ids
      assign_skills(@project, all_skill_ids.uniq)
      render :show, status: :ok
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    if current_user&.id != @project.client_id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    else
      @project.destroy
      head :no_content
    end
  end

  private

  def set_project
    @project = Project.find_by(id: params[:id])
    render json: { error: "Project not found." }, status: :not_found unless @project
  end

  def project_params
    params.require(:project).permit(:title, :description, :budget, :deadline, :new_skills, skill_ids: [])
  end

  # Only allow actual user clients to create/update/destroy
  def authorize_client_user!
    unless current_user&.client?
      render json: { error: "Only client users can manage projects." }, status: :forbidden
    end
  end

  def assign_skills(project, skill_ids)
    project.skill_assignments.destroy_all
    skill_ids.each do |skill_id|
      project.skill_assignments.create(skill_id: skill_id)
    end
  end

  def process_new_skills(raw_new_skills)
    raw_new_skills.to_s.split(',').map(&:strip).reject(&:blank?).map do |skill_name|
      Skill.find_or_create_by(skill_name: skill_name.downcase).id
    end
  end
end
