class CommentsController < ApplicationController
  def create
  @comment = Comment.new(comment_params)
  @comment.user = current_user
  if @comment.save
    redirect_to dashboard_path, notice: 'Comment added.'
  else
    redirect_to dashboard_path, alert: 'Failed to add comment.'
  end
end

def update
  @comment = Comment.find(params[:id])
  @comment.update(comment_params)
  redirect_to dashboard_path
end

def destroy
  @comment = Comment.find(params[:id])
  @comment.destroy
  redirect_to dashboard_path
end

private

def comment_params
  params.require(:comment).permit(:body, :commentable_type, :commentable_id)
end

end
