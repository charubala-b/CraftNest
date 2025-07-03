class Api::V1::ReviewsController < Api::V1::BaseController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :set_review, only: [:show]

  def show
    if @review
      render :show, formats: :json, status: :ok
    else
      render json: { message: "Review not found" }, status: :not_found
    end
  end

  def create
    reviewer_id = current_user.id
    project_id = review_params[:project_id]

    existing_review = Review.find_by(project_id: project_id, reviewer_id: reviewer_id)

    if existing_review
      render json: { message: "You have already submitted a review for this project." }, status: :unprocessable_entity
      return
    end

    @review = Review.new(review_params.merge(reviewer_id: reviewer_id))

    if @review.save
      render :show, formats: :json, status: :created
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_review
    @review = Review.find_by(project_id: params[:project_id], reviewer_id: params[:reviewer_id])
  end

  def review_params
    params.require(:review).permit(:ratings, :review, :project_id, :reviewee_id)
  end
end
