class CommentsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      flash[:notice] = 'Comment posted.'
    else
      flash[:alert] = 'Failed to post comment.'
    end

    redirect_to appropriate_dashboard_path
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:notice] = 'Comment deleted.'
    
    redirect_to appropriate_dashboard_path
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def appropriate_dashboard_path
    if current_user.client?
      client_dashboard_path
    elsif current_user.freelancer?
      freelancer_dashboard_path
    else
      root_path
    end
  end
end
