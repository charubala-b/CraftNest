require 'rails_helper'

RSpec.describe 'API::V1::Comments', type: :request do
  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }
  let(:project)    { create(:project, client: client) }
  let(:contract)   { create(:contract, project: project, freelancer: freelancer, client: client) }

  let(:base_url) { '/api/v1/comments' }
  let(:project_comments_url) { "/api/v1/projects/#{project.id}/comments" }

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
      get project_comments_url, headers: client_headers
      aggregate_failures 'allowing client to view' do
        expect(response).to have_http_status(:ok)
        expect(json_response.first['comment']['body']).to eq(comment.body)
      end
    end

    it 'returns forbidden for another client' do
      another_client = create(:user, :client)
      token = create(:doorkeeper_access_token, resource_owner_id: another_client.id)

      get project_comments_url, headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      aggregate_failures 'validating client' do
        expect(response).to have_http_status(:forbidden)
        expect(json_response['errors']).to include('Forbidden: You can only view comments on your own projects.')
      end
    end
  end

  describe 'POST /api/v1/projects/:project_id/comments' do
    it 'allows client to create a comment' do
      post project_comments_url, params: {
        comment: { body: "Test comment created fully" }
      }.to_json, headers: client_headers

      aggregate_failures 'creating the comment' do
        expect(response).to have_http_status(:created)
        expect(json_response['comment']['body']).to eq("Test comment created fully")
      end
    end

    it 'allows freelancer on contract to comment' do
      contract # ensure contract is created

      post project_comments_url, params: {
        comment: { body: "Freelancer comment created" }
      }.to_json, headers: freelancer_headers

      aggregate_failures 'creating comment by freelancer' do
        expect(response).to have_http_status(:created)
        expect(json_response['comment']['body']).to eq("Freelancer comment created")
      end
    end

    it 'forbids freelancer not on contract from commenting' do
      other_freelancer = create(:user, :freelancer)
      token = create(:doorkeeper_access_token, resource_owner_id: other_freelancer.id)

      post project_comments_url, params: {
        comment: { body: "Invalid comment" }
      }.to_json, headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      aggregate_failures 'validating comments' do
        expect(response).to have_http_status(:forbidden)
        expect(json_response['errors']).to include("Forbidden: Freelancers can only comment on assigned projects.")
      end
    end
  end

  describe 'PATCH /api/v1/comments/:id' do
    let!(:comment) { create(:comment, project: project, user: client) }
    let(:comment_url) { "#{base_url}/#{comment.id}" }

    it 'allows owner to update comment' do
      patch comment_url, params: {
        comment: { body: "Updated body completed" }
      }.to_json, headers: client_headers

      aggregate_failures 'updating the comment status' do
        expect(response).to have_http_status(:ok)
        expect(json_response['comment']['body']).to eq("Updated body completed")
      end
    end

    it 'forbids non-owner to update comment' do
      patch comment_url, params: {
        comment: { body: "Hack attempt" }
      }.to_json, headers: freelancer_headers

      aggregate_failures 'validating owner' do
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['errors']).to include("Unauthorized: You can only edit your own comments.")
      end
    end
  end

  describe 'DELETE /api/v1/comments/:id' do
    let!(:comment) { create(:comment, project: project, user: client) }
    let(:comment_url) { "#{base_url}/#{comment.id}" }

    it 'allows client to delete their own project comment' do
      delete comment_url, headers: client_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'forbids freelancer from deleting comment' do
      delete comment_url, headers: freelancer_headers
      aggregate_failures 'checking freelancer from deleting the comment' do
        expect(response).to have_http_status(:forbidden)
        expect(json_response['errors']).to include("Forbidden: Freelancers cannot delete comments.")
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
