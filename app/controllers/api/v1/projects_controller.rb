module Api
  module V1
    class ProjectsController < BaseController
      before_action :doorkeeper_authorize!
      before_action :set_project, only: [ :show, :update, :destroy ]
      before_action :authorize_client!, only: [ :create, :update, :destroy ]

      def index
        if current_user_api&.client?
          @projects = current_user_api.projects.includes(:skills)
        elsif current_user_api&.freelancer? || current_application
          @projects = Project.includes(:skills).all
        else
          @projects = []
        end

        render :index
      end

      def show
        if current_user_api&.client? && @project.client_id != current_user_api.id
          render json: { error: "Unauthorized access." }, status: :unauthorized
        else
          render :show
        end
      end

      def create
        @project = current_user_api.projects.build(project_params.except(:skill_ids, :new_skills))

        if @project.budget.present? && @project.budget.to_f < 0
          return render json: { errors: [ "Budget must be a non-negative number" ] }, status: :unprocessable_entity
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

      def update
        unless @project.client_id == current_user_api&.id
          return render json: { error: "Unauthorized action." }, status: :unauthorized
        end

        if project_params[:budget].to_f < 0
          return render json: { errors: [ "Budget must be a non-negative number" ] }, status: :unprocessable_entity
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

      def destroy
        unless @project.client_id == current_user_api&.id
          return render json: { error: "Unauthorized action." }, status: :unauthorized
        end

        @project.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find_by(id: params[:id])
        render json: { error: "Project not found." }, status: :not_found unless @project
      end

      def project_params
        params.require(:project).permit(:title, :description, :budget, :deadline, :new_skills, skill_ids: [])
      end

      def assign_skills(project, skill_ids)
        project.skill_assignments.destroy_all
        skill_ids.each do |skill_id|
          project.skill_assignments.create(skill_id: skill_id)
        end
      end

      def process_new_skills(raw_new_skills)
        return [] unless raw_new_skills.present?

        raw_new_skills.to_s.split(",").map(&:strip).reject(&:blank?).map do |skill_name|
          Skill.find_or_create_by(skill_name: skill_name.downcase).id
        end
      end
    end
  end
end
