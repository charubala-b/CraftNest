module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_project
      before_action :authorize_client!

def show
  review = @project.reviews.find_by(reviewer_id: current_user_api.id)

  if review
    render json: review, status: :ok
  else
    render json: { error: 'Review not found' }, status: :not_found
  end
end


def create
  contract = Contract.find_by(project_id: @project.id)
  unless contract
    return render json: { error: 'Contract not found for this project' }, status: :unprocessable_entity
  end

  review = @project.reviews.build(
    review_params.merge(
      reviewer_id: current_user_api.id,
      reviewee_id: contract.freelancer_id
    )
  )


  if review.save
    render json: review, status: :created
  else
    render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
  end
end


      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def review_params
        params.require(:review).permit(:ratings, :review)
      end
    end
  end
end
