class ReviewsController < ApplicationController
  def new
    @review = Review.new(
      reviewee_id: params[:reviewee_id],
      project_id: params[:project_id]
    )
  end

  def create
    @review = current_user.reviews_given.build(review_params)
    if @review.save
      redirect_to dashboard_path, notice: "Review submitted successfully."
    else
      render :new
    end
  end

  private

  def review_params
    params.require(:review).permit(:reviewee_id, :project_id, :ratings, :review)
  end
end
