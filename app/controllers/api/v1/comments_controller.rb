class Api::V1::CommentsController < Api::V1::BaseController
  before_action :set_project, only: [:index, :create]
  before_action :set_comment, only: [:show, :update, :destroy]

  def index
    if current_user_api.client? && @project.client_id != current_user_api.id
      return render json: { errors: ['Forbidden: You can only view comments on your own projects.'] }, status: :forbidden
    end

    @comments = @project.comments.includes(:user)
    render :index
  end

  def show
    if current_user_api.client? && @comment.project.client_id != current_user_api.id
      render json: { errors: ['Forbidden: You can only view comments on your own projects.'] }, status: :forbidden
    else
      render :show
    end
  end

  def create
    if current_user_api.client? && @project.client_id != current_user_api.id
      return render json: { errors: ['Forbidden: Clients can only comment on their own projects.'] }, status: :forbidden
    end

    if current_user_api.freelancer?
      unless Contract.exists?(project_id: @project.id, freelancer_id: current_user_api.id)
        return render json: { errors: ['Forbidden: Freelancers can only comment on assigned projects.'] }, status: :forbidden
      end
    end

    if comment_params[:parent_id].present?
      parent_comment = Comment.find_by(id: comment_params[:parent_id])
      unless parent_comment && parent_comment.project_id == @project.id
        return render json: { errors: ['Invalid parent comment.'] }, status: :unprocessable_entity
      end
    end

    @comment = @project.comments.build(comment_params)
    @comment.user = current_user_api

    if @comment.save
      render :show, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.user != current_user_api
      render json: { errors: ['Unauthorized: You can only edit your own comments.'] }, status: :unauthorized
    elsif @comment.update(comment_params)
      render :show
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user_api.client?
      if @comment.project.client_id == current_user_api.id
        @comment.destroy
        head :no_content
      else
        render json: { errors: ['Forbidden: You can only delete comments on your own projects.'] }, status: :forbidden
      end
    elsif current_user_api.freelancer?
      render json: { errors: ['Forbidden: Freelancers cannot delete comments.'] }, status: :forbidden
    else
      render json: { errors: ['Unauthorized user.'] }, status: :unauthorized
    end
  end

  private

  def set_project
    @project = Project.find_by(id: params[:project_id])
    render json: { errors: ['Project not found.'] }, status: :not_found unless @project
  end

  def set_comment
    @comment = Comment.includes(:project).find_by(id: params[:id])
    render json: { errors: ['Comment not found.'] }, status: :not_found unless @comment
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
