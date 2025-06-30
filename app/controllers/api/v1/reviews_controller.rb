module Api
  module V1
    class ReviewsController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def show
        review = Review.find_by(project_id: params[:project_id], reviewer_id: params[:reviewer_id])
        if review
          render json: review, status: :ok
        else
          render json: { message: "Not found" }, status: :not_found
        end
      end

    def create
    review = Review.new(review_params.merge(reviewer_id: current_user.id))
    if review.save
        render json: { message: "Review submitted", review: review }, status: :created
    else
        render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
    end
    end


      private

      def review_params
        params.require(:review).permit(:ratings, :review, :project_id, :reviewee_id)
      end
    end
  end
end
