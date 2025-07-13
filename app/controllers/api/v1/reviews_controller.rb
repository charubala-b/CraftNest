class Api::V1::ReviewsController < Api::V1::BaseController
  before_action :set_project
  before_action :set_review, only: [:show]

  def show
    unless authorized_to_view_review?(@project)
      return render json: { error: "Forbidden: You cannot view this review." }, status: :forbidden
    end

    if @review
      render :show, formats: :json, status: :ok
    else
      render json: { message: "Review not found" }, status: :not_found
    end
  end

  def create
    
    unless authorized_to_create_review?(@project)
      return render json: { error: "Forbidden: You are not allowed to review this project." }, status: :forbidden
    end

    if Review.exists?(project_id: @project.id, reviewer_id: current_user.id)
      return render json: { message: "You have already submitted a review for this project." }, status: :unprocessable_entity
    end

    @review = Review.new(review_params.merge(reviewer_id: current_user.id))

    if @review.save
      render :show, formats: :json, status: :created
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_project
    project_id = params[:project_id] || params.dig(:review, :project_id)
    @project = Project.find_by(id: project_id)
    render json: { error: "Project not found." }, status: :not_found unless @project
  end


  def set_review
    @review = Review.find_by(project_id: @project.id)
  end


  def review_params
    params.require(:review).permit(:ratings, :review, :project_id, :reviewee_id)
  end


  def authorized_to_view_review?(project)
    if current_user.client?
      project.client_id == current_user.id
    elsif current_user.freelancer?
      Contract.exists?(project_id: project.id, freelancer_id: current_user.id)
    else
      false
    end
  end

  def authorized_to_create_review?(project)
    authorized_to_view_review?(project)
  end
end
