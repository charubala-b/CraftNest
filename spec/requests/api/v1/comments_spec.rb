require 'rails_helper'

RSpec.describe 'API::V1::Comments', type: :request do
  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }
  let(:project)    { create(:project, client: client) }
  let(:contract)   { create(:contract, project: project, freelancer: freelancer, client: client) }

  let(:client_token) do
    create(:doorkeeper_access_token, resource_owner_id: client.id, scopes: 'read write')
  end

  let(:freelancer_token) do
    create(:doorkeeper_access_token, resource_owner_id: freelancer.id, scopes: 'read write')
  end

  let(:client_headers) do
    {
      'Authorization' => "Bearer #{client_token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  let(:freelancer_headers) do
    {
      'Authorization' => "Bearer #{freelancer_token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  describe 'GET /api/v1/projects/:project_id/comments' do
    let!(:comment) { create(:comment, project: project, user: client) }

    it 'allows client to view their own project comments' do
      get "/api/v1/projects/#{project.id}/comments", headers: client_headers

      expect(response).to have_http_status(:ok)
      expect(json_response.first['comment']['body']).to eq(comment.body)
    end

    it 'returns forbidden for another client' do
      another_client = create(:user, :client)
      token = create(:doorkeeper_access_token, resource_owner_id: another_client.id)
      get "/api/v1/projects/#{project.id}/comments", headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      expect(response).to have_http_status(:forbidden)
      expect(json_response['errors']).to include('Forbidden: You can only view comments on your own projects.')
    end
  end

  describe 'POST /api/v1/projects/:project_id/comments' do
    it 'allows client to create a comment' do
      post "/api/v1/projects/#{project.id}/comments", params: {
        comment: { body: "Test comment created fully" }
      }.to_json, headers: client_headers

      expect(response).to have_http_status(:created)
      expect(json_response['comment']['body']).to eq("Test comment created fully")
    end

    it 'allows freelancer on contract to comment' do
      contract # ensure contract exists

      post "/api/v1/projects/#{project.id}/comments", params: {
        comment: { body: "Freelancer comment created" }
      }.to_json, headers: freelancer_headers

      expect(response).to have_http_status(:created)
      expect(json_response['comment']['body']).to eq("Freelancer comment created")
    end

    it 'forbids freelancer not on contract from commenting' do
      other_freelancer = create(:user, :freelancer)
      token = create(:doorkeeper_access_token, resource_owner_id: other_freelancer.id)

      post "/api/v1/projects/#{project.id}/comments", params: {
        comment: { body: "Invalid comment" }
      }.to_json, headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      expect(response).to have_http_status(:forbidden)
      expect(json_response['errors']).to include("Forbidden: Freelancers can only comment on assigned projects.")
    end
  end

  describe 'PATCH /api/v1/comments/:id' do
    let!(:comment) { create(:comment, project: project, user: client) }

    it 'allows owner to update comment' do
      patch "/api/v1/comments/#{comment.id}", params: {
        comment: { body: "Updated body completed" }
      }.to_json, headers: client_headers

      expect(response).to have_http_status(:ok)
      expect(json_response['comment']['body']).to eq("Updated body completed")
    end

    it 'forbids non-owner to update comment' do
      patch "/api/v1/comments/#{comment.id}", params: {
        comment: { body: "Hack attempt" }
      }.to_json, headers: freelancer_headers

      expect(response).to have_http_status(:unauthorized)
      expect(json_response['errors']).to include("Unauthorized: You can only edit your own comments.")
    end
  end

  describe 'DELETE /api/v1/comments/:id' do
    let!(:comment) { create(:comment, project: project, user: client) }

    it 'allows client to delete their own project comment' do
      delete "/api/v1/comments/#{comment.id}", headers: client_headers

      expect(response).to have_http_status(:no_content)
    end

    it 'forbids freelancer from deleting comment' do
      delete "/api/v1/comments/#{comment.id}", headers: freelancer_headers

      expect(response).to have_http_status(:forbidden)
      expect(json_response['errors']).to include("Forbidden: Freelancers cannot delete comments.")
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
