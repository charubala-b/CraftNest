class CommentsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @comment = @project.comments.build(comment_params.merge(user_id: current_user.id))
    if @comment.save
      redirect_to dashboard_path, notice: "Comment added."
    else
      redirect_to dashboard_path, alert: "Failed to add comment."
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to dashboard_path, notice: "Comment deleted."
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
