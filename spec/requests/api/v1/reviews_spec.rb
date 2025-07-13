require 'rails_helper'

RSpec.describe "API::V1::Reviews", type: :request do
  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }
  let(:project)    { create(:project, client: client) }
  let!(:contract)  { create(:contract, project: project, freelancer: freelancer, client: client) }

  let!(:application) { Doorkeeper::Application.create!(name: "Test App", redirect_uri: "https://example.com") }

  let(:review_path)  { ->(project_id) { "/api/v1/reviews/#{project_id}" } }
  let(:reviews_path) { "/api/v1/reviews" }

  let(:review_params) do
    {
      review: {
        ratings: 5,
        review: "Excellent work you have done !",
        project_id: project.id,
        reviewee_id: freelancer.id
      }
    }
  end

  def auth_headers(user)
    token = Doorkeeper::AccessToken.create!(
      application_id: application.id,
      resource_owner_id: user.id,
      scopes: 'public'
    ).token
    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/reviews/:project_id" do
    context "when review exists and authorized" do
      let!(:review) { create(:review, project: project, reviewer: client, reviewee: freelancer, review: "The project has been carried out excellently") }

      it "allows client to view their review" do
        get review_path.call(project.id), headers: auth_headers(client)

        aggregate_failures "client views review" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["review"]["review"]).to eq("The project has been carried out excellently")
        end
      end

      it "allows freelancer to view review" do
        get review_path.call(project.id), headers: auth_headers(freelancer)

        aggregate_failures "freelancer views review" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["review"]["review"]).to eq("The project has been carried out excellently")
        end
      end
    end

    context "when unauthorized user tries to access" do
      let(:unauthorized_user) { create(:user) }

      it "returns forbidden" do
        get review_path.call(project.id), headers: auth_headers(unauthorized_user)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when review does not exist" do
      it "returns not_found" do
        get review_path.call(project.id), headers: auth_headers(client)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user with no valid role tries to view review" do
      let(:weird_user) { create(:user, role: nil) }

      it "returns forbidden" do
        get review_path.call(project.id), headers: auth_headers(weird_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/reviews" do
    context "when client creates a review" do
      before { contract.update!(status: :completed) }

      it "creates the review successfully" do
        post reviews_path, params: review_params, headers: auth_headers(client)

        aggregate_failures "successful review creation" do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body["review"]["review"]).to eq("Excellent work you have done !")
        end
      end
    end

    context "when freelancer tries to submit a review" do
      it "creates the review for reverse direction" do
        invalid_params = review_params.deep_dup
        invalid_params[:review][:reviewee_id] = client.id

        post reviews_path, params: invalid_params, headers: auth_headers(freelancer)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unrelated user tries to review" do
      let(:stranger) { create(:user) }

      it "returns forbidden" do
        post reviews_path, params: review_params, headers: auth_headers(stranger)

        aggregate_failures "unauthorized review" do
          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body["error"]).to include("not allowed to review")
        end
      end
    end

    context "when review already exists" do
      before do
        create(:review, project: project, reviewer: client, reviewee: freelancer)
      end

      it "returns unprocessable_entity" do
        post reviews_path, params: review_params, headers: auth_headers(client)

        aggregate_failures "duplicate review" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["message"]).to include("already submitted")
        end
      end
    end

    context "when creation fails due to validation errors" do
      it "returns unprocessable_entity with errors" do
        post reviews_path, params: {
          review: {
            project_id: project.id,
            reviewee_id: freelancer.id,
            ratings: nil,
            review: ""
          }
        }, headers: auth_headers(client)

        aggregate_failures "validation error" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to be_present
        end
      end
    end
  end
end
