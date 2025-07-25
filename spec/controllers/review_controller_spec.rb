require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
    include Devise::Test::ControllerHelpers

    let (:user) {create(:user)}
    let (:reviewee) {create(:user)}
    let (:project) {create(:project)}

    describe 'get#new' do
        context 'when the user is not signed in' do
            it 'redirect to login page again' do
                get :new, params: {reviewee_id: reviewee.id, project_id: project.id }
                expect(response). to redirect_to(new_user_session_path)
            end
        end

        context 'when user is signed in' do
            before {sign_in user}
            it 'assign to new review' do
                get :new, params: {reviewee_id: reviewee.id,project_id: project.id }
                expect(assigns(:review)).to be_a_new(Review)
                expect(assigns(:project)).to eq(project)
                expect(assigns(:reviewee)).to eq(reviewee)
            end
        end

    end

    describe 'creating a review' do
        let(:valid_review_params) do
        {
            ratings: 5,
            review: "Great work done by you!!",
            project_id: project.id,
            reviewee_id: reviewee.id
        }
        end

        context 'when the user is not signed in' do 
            it 'redirects to login page' do
                post :create, params: {review: valid_review_params}
                expect(response).to redirect_to(new_user_session_path)
            end
        end
        context 'when user is signed in' do
            before {sign_in user}
            context 'when the user has not submitted the review before' do
                it 'create a review' do
                    expect{post :create, params: {review: valid_review_params}}.to change(Review, :count).by(1)
                    expect(response).to redirect_to(dashboard_path)
                    expect(flash[:notice]).to eq("Review submitted successfully.")
                end
            end
            context 'when user has already submitted the review' do
                it 'redirect to the dashboard with the alet message' do
                    create(:review, reviewer_id: user.id, project_id: project.id)
                    post :create, params: {review: valid_review_params}
                    expect(response).to redirect_to(dashboard_path)
                    expect(flash[:alert]).to eq("You have already submitted a review for this project.")
                end
            end
            context 'when the review is valid' do
                it 'creates a review and redirects to the dashboard' do
                    post :create, params: {review: valid_review_params}
                    expect(response).to redirect_to(dashboard_path)
                    expect(flash[:notice]).to eq("Review submitted successfully.")
                    expect(Review.last.ratings).to eq(valid_review_params[:ratings])
                    expect(Review.last.review).to eq(valid_review_params[:review])
                end
            end

            context 'when the review is invalid' do
                it 'does not create a review and redirects with an alert' do
                    invalid_review_params = valid_review_params.merge(ratings: nil, review: nil)
                    post :create, params: {review: invalid_review_params}
                    expect(response).to redirect_to(dashboard_path)
                    expect(flash[:alert]).to eq("Failed to submit review.")
                    expect(Review.count).to eq(0) # Assuming no reviews were created
                end
            end
        end
    end
end

