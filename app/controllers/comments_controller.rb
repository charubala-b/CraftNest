class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :create ]
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      flash[:notice] = "Comment posted."
    else
      flash[:alert] = "Failed to post comment."
    end

    redirect_to appropriate_dashboard_path
  end

  def destroy
    if @comment.user == current_user || current_user.client? && @comment.project.client_id == current_user.id
      @comment.destroy
      flash[:notice] = "Comment deleted."
    else
      flash[:alert] = "You are not authorized to delete this comment."
    end

    redirect_to appropriate_dashboard_path
  end

  private

  def set_project
    @project = Project.find_by(id: params[:project_id])
    redirect_to root_path, alert: "Project not found." unless @project
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    redirect_to root_path, alert: "Comment not found." unless @comment
  end

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
