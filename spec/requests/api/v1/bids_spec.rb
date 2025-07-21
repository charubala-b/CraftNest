require 'rails_helper'

RSpec.describe 'API::V1::Bids', type: :request do
  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }
  let(:project)    { create(:project, client: client) }

  let(:freelancer_token) do
    create(:doorkeeper_access_token, resource_owner_id: freelancer.id, scopes: 'read write')
  end

  let(:client_token) do
    create(:doorkeeper_access_token, resource_owner_id: client.id, scopes: 'read write')
  end

  let(:freelancer_headers) do
    {
      'Authorization' => "Bearer #{freelancer_token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  let(:client_headers) do
    {
      'Authorization' => "Bearer #{client_token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  let(:base_url) { '/api/v1/bids' }

  describe 'GET /api/v1/bids' do
    let!(:bid) { create(:bid, project: project, user: freelancer) }

    it 'returns bids for client' do
      get base_url, headers: client_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns bids for freelancer' do
      get base_url, headers: freelancer_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/projects/:project_id/bids' do
    let(:project_bids_url) { "/api/v1/projects/#{project.id}/bids" }

    let(:valid_params) do
      {
        bid: {
          cover_letter: "Excited to work on this project!",
          proposed_price: 1000
        }
      }.to_json
    end

    it 'creates a bid successfully' do
      post project_bids_url, params: valid_params, headers: freelancer_headers
      aggregate_failures 'creating bids' do
        expect(response).to have_http_status(:created)
        expect(json_response['bid']['cover_letter']).to eq("Excited to work on this project!")
      end
    end

    it 'returns error if project not found' do
      post "/api/v1/projects/9999/bids", params: valid_params, headers: freelancer_headers
      aggregate_failures 'checking error' do
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq("Project not found.")
      end
    end
  end

  describe 'PATCH /api/v1/bids/:id' do
    let!(:bid) { create(:bid, project: project, user: freelancer) }
    let(:bid_url) { "#{base_url}/#{bid.id}" }

    it 'updates the bid if freelancer is owner' do
      patch bid_url, params: {
        bid: { proposed_price: 1500 }
      }.to_json, headers: freelancer_headers

      aggregate_failures 'updating the bids' do
        expect(response).to have_http_status(:ok)
        expect(json_response['bid']['proposed_price']).to eq("1500.0")
      end
    end

    it 'returns unauthorized if another freelancer tries to update' do
      other_freelancer = create(:user, :freelancer)
      token = create(:doorkeeper_access_token, resource_owner_id: other_freelancer.id, scopes: 'read write')

      patch bid_url, params: {
        bid: { proposed_price: 2000 }
      }.to_json, headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/bids/:id' do
    let!(:bid) { create(:bid, project: project, user: freelancer) }
    let(:bid_url) { "#{base_url}/#{bid.id}" }

    it 'deletes a bid if freelancer is owner' do
      delete bid_url, headers: freelancer_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns forbidden if bid is accepted' do
      bid.update!(accepted: true)
      delete bid_url, headers: freelancer_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/v1/bids/:id/accept' do
    let!(:bid) { create(:bid, project: project, user: freelancer) }
    let(:accept_bid_url) { "#{base_url}/#{bid.id}/accept" }

    it 'accepts the bid if client is owner of project' do
      post accept_bid_url, headers: client_headers
      aggregate_failures 'accepting the bid' do
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq("Bid accepted successfully.")
      end
    end

    it 'returns unauthorized if client does not own the project' do
      other_client = create(:user, :client)
      token = create(:doorkeeper_access_token, resource_owner_id: other_client.id)

      post accept_bid_url, headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
