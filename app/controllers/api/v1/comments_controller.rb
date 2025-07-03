class Api::V1::CommentsController < Api::V1::BaseController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :set_project, only: [:create]
  before_action :set_comment, only: [:show, :update, :destroy]

  def show
    render :show
  end

  def create
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
      render json: { error: 'Unauthorized' }, status: :unauthorized
    elsif @comment.update(comment_params)
      render :show
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if can_delete_comment?
      @comment.destroy
      render json: { message: 'Comment deleted' }, status: :ok
    else
      render json: { error: 'You are not authorized to delete this comment.' }, status: :unauthorized
    end
  end

  private

  def set_project
    @project = Project.find_by(id: params[:project_id])
    render json: { error: 'Project not found' }, status: :not_found unless @project
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    render json: { error: 'Comment not found' }, status: :not_found unless @comment
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def can_delete_comment?
    # Author can delete OR client who owns the project can delete any comment
    @comment.user == current_user || (
      current_user.client? && @comment.project.client_id == current_user.id
    )
  end
end
