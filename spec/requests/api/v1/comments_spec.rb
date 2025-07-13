require 'rails_helper'

RSpec.describe "API::V1::Comments", type: :request do
  let!(:client) { create(:user, role: :client) }
  let!(:freelancer) { create(:user, role: :freelancer) }
  let!(:project) { create(:project, client: client) }
  let!(:comment) { create(:comment, project: project, user: freelancer) }

  let(:client_token) { create(:access_token, resource_owner_id: client.id) }
  let(:freelancer_token) { create(:access_token, resource_owner_id: freelancer.id) }

  let(:client_headers) { { "Authorization" => "Bearer #{client_token.token}" } }
  let(:freelancer_headers) { { "Authorization" => "Bearer #{freelancer_token.token}" } }

  def auth_headers(user)
    token = Doorkeeper::AccessToken.create!(
      application_id: Doorkeeper::Application.create!(name: "Test App", redirect_uri: "https://example.com").id,
      resource_owner_id: user.id,
      scopes: 'public'
    ).token

    { "Authorization" => "Bearer #{token}" }
  end

  
  let(:project_comments_path) { ->(project_id) { "/api/v1/projects/#{project_id}/comments" } }
  let(:comment_path) { ->(id) { "/api/v1/comments/#{id}" } }

  describe "GET /api/v1/projects/:project_id/comments" do
    it "returns comments for client's project" do
      get project_comments_path.call(project.id), headers: client_headers
      expect(response).to have_http_status(:ok)
    end

    it "forbids access to other client's project comments" do
      other_project = create(:project)
      get project_comments_path.call(other_project.id), headers: client_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/comments/:id" do
    it "allows freelancer to view comment" do
      get comment_path.call(comment.id), headers: freelancer_headers
      expect(response).to have_http_status(:ok)
    end

    it "forbids client from viewing another client's project comment" do
      other_project = create(:project)
      other_comment = create(:comment, project: other_project)
      get comment_path.call(other_comment.id), headers: client_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/projects/:project_id/comments" do
    let(:valid_params) { { comment: { body: "This is a great project!" } } }

    it "allows freelancer to comment on any project" do
      post project_comments_path.call(project.id), params: valid_params, headers: freelancer_headers
      aggregate_failures "freelancer comment creation" do
        expect(response).to have_http_status(:created)
        expect(json["comment"]["body"]).to eq("This is a great project!")
      end
    end

    it "allows client to comment on their own project" do
      post project_comments_path.call(project.id), params: valid_params, headers: client_headers
      expect(response).to have_http_status(:created)
    end

    it "forbids client to comment on another client's project" do
      other_project = create(:project)
      post project_comments_path.call(other_project.id), params: valid_params, headers: client_headers
      expect(response).to have_http_status(:forbidden)
    end

    context "when comment creation fails due to validation errors" do
      it "returns unprocessable_entity" do
        post project_comments_path.call(project.id), params: {
          comment: { body: "" }
        }, headers: auth_headers(client)

        aggregate_failures "validation error" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("Body can't be blank")
        end
      end
    end
  end

  describe "PATCH /api/v1/comments/:id" do
    it "allows comment owner to update" do
      patch comment_path.call(comment.id), params: { comment: { body: "Updated comment for projects" } }, headers: freelancer_headers
      aggregate_failures "comment update" do
        expect(response).to have_http_status(:ok)
        expect(json["comment"]["body"]).to eq("Updated comment for projects")
      end
    end

    it "forbids others from updating comment" do
      patch comment_path.call(comment.id), params: { comment: { body: "Hacked!" } }, headers: client_headers
      expect(response).to have_http_status(:unauthorized)
    end

    context "when comment update fails due to validation" do
      let!(:comment) { create(:comment, user: client, project: project) }

      it "returns unprocessable_entity" do
        patch comment_path.call(comment.id), params: {
          comment: { body: "" }
        }, headers: auth_headers(client)

        aggregate_failures "update validation error" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("Body can't be blank")
        end
      end
    end
  end

  describe "DELETE /api/v1/comments/:id" do
    it "allows project owner (client) to delete comment" do
      delete comment_path.call(comment.id), headers: client_headers
      expect(response).to have_http_status(:no_content)
    end

    it "forbids freelancer from deleting comment" do
      delete comment_path.call(comment.id), headers: freelancer_headers
      expect(response).to have_http_status(:forbidden)
    end

    context "when client tries to delete comment on another's project" do
      let(:other_client) { create(:user, :client) }
      let(:other_project) { create(:project, client: other_client) }
      let!(:comment) { create(:comment, project: other_project, user: freelancer) }

      it "returns forbidden" do
        delete comment_path.call(comment.id), headers: auth_headers(client)

        aggregate_failures "unauthorized delete attempt" do
          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body["error"]).to include("only delete comments on your own projects")
        end
      end
    end

    context "when unauthorized user tries to delete a comment" do
      let(:random_user) { create(:user, role: nil) }
      let!(:comment) { create(:comment, project: project, user: freelancer) }

      it "returns unauthorized" do
        delete comment_path.call(comment.id), headers: auth_headers(random_user)

        aggregate_failures "unauthorized user delete" do
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["error"]).to include("Unauthorized user")
        end
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
