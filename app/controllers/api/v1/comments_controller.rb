class Api::V1::CommentsController < Api::V1::BaseController
  before_action :set_project, only: [:index, :create]
  before_action :set_comment, only: [:show, :update, :destroy]

  def index
    if current_user.client?
      if @project.client_id != current_user.id
        return render json: { error: 'Forbidden: You can only view comments on your own projects.' }, status: :forbidden
      end
    end

    @comments = @project.comments.includes(:user)
    render :index
  end

  def show
    if current_user.client? && @comment.project.client_id != current_user.id
      render json: { error: 'Forbidden: You can only view comments on your own projects.' }, status: :forbidden
    else
      render :show
    end
  end

  def create
    if current_user.client? && @project.client_id != current_user.id
      return render json: { error: 'Forbidden: Clients can only comment on their own projects.' }, status: :forbidden
    end

    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      render :show, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.user != current_user
      render json: { error: 'Unauthorized: You can only edit your own comments.' }, status: :unauthorized
    elsif @comment.update(comment_params)
      render :show
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.client?
      if @comment.project.client_id == current_user.id
        @comment.destroy
        head :no_content
      else
        render json: { error: 'Forbidden: You can only delete comments on your own projects.' }, status: :forbidden
      end
    elsif current_user.freelancer?
      render json: { error: 'Forbidden: Freelancers cannot delete comments.' }, status: :forbidden
    else
      render json: { error: 'Unauthorized user.' }, status: :unauthorized
    end
  end

  private

  def set_project
    @project = Project.find_by(id: params[:project_id])
    render json: { error: 'Project not found.' }, status: :not_found unless @project
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    render json: { error: 'Comment not found.' }, status: :not_found unless @comment
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
