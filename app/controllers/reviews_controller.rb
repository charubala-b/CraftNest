class ReviewsController < ApplicationController
  def new
    @review = Review.new
    @project = Project.find(params[:project_id])
    @reviewee = User.find(params[:reviewee_id])
  end

  def create
    reviewer_id = session[:user_id]
    project_id = params[:review][:project_id]

    existing_review = Review.find_by(reviewer_id: reviewer_id, project_id: project_id)
    if existing_review
      redirect_to redirect_path_based_on_role, alert: "You have already submitted a review for this project." and return
    end

    @review = Review.new(review_params)
    @review.reviewer_id = reviewer_id

    if @review.save
      redirect_to redirect_path_based_on_role, notice: "Review submitted successfully."
    else
      redirect_to redirect_path_based_on_role, alert: "Failed to submit review."
    end
  end

  private

  def review_params
    params.require(:review).permit(:ratings, :review, :project_id, :reviewee_id)
  end

  def redirect_path_based_on_role
    current_user.freelancer? ? freelancer_dashboard_path : dashboard_path
  end
end
