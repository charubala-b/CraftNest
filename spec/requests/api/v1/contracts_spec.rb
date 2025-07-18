require 'rails_helper'

RSpec.describe 'API::V1::Contracts', type: :request do
  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }
  let(:project)    { create(:project, client: client) }

  let(:token) do
    create(:doorkeeper_access_token, resource_owner_id: client.id, scopes: 'read write')
  end
  

  let(:headers) do
    {
      'Authorization' => "Bearer #{token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  describe 'GET /api/v1/contracts/:id' do
    let!(:contract) { create(:contract, project: project, client: client, freelancer: freelancer) }

    context 'when authorized' do
      it 'returns the contract' do
        get "/api/v1/contracts/#{contract.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['contract']['id']).to eq(contract.id)
        puts response.body
        expect(json_response['contract']['project']['id']).to eq(project.id)
      end
    end

    context 'when unauthorized' do
      let(:unauthorized_user) { create(:user, :client) }
      let(:unauthorized_token) do
        create(:doorkeeper_access_token, resource_owner_id: unauthorized_user.id, scopes: 'read write')
      end

      it 'returns 401 unauthorized' do
        get "/api/v1/contracts/#{contract.id}", headers: {
          'Authorization' => "Bearer #{unauthorized_token.token}",
          'Content-Type' => 'application/json'
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq("You are not authorized to view this contract.")
      end
    end
  end

  describe 'POST /api/v1/contracts' do
    let(:valid_params) do
      {
        contract: {
          project_id: project.id,
          freelancer_id: freelancer.id
        }
      }.to_json
    end

    it 'creates a contract successfully' do
      post '/api/v1/contracts', params: valid_params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json_response['contract']['project']['id']).to eq(project.id)
      puts response.body
      expect(json_response['contract']['freelancer']['id']).to eq(freelancer.id)
      expect(json_response['contract']['status']).to eq('active')
    end

    it 'returns validation error if project_id is missing' do
      post '/api/v1/contracts', params: {
        contract: {
          freelancer_id: freelancer.id
        }
      }.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['errors']).to include("Project must exist")
    end
  end

  describe 'PATCH /api/v1/contracts/:id' do
    let!(:contract) { create(:contract, client: client, freelancer: freelancer, project: project, status: :active) }

    it 'updates the contract status to completed' do
      patch "/api/v1/contracts/#{contract.id}", params: {
        contract: { status: 'completed' }
      }.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['contract']['status']).to eq('completed')
    end

    it 'returns 401 if client is not owner' do
      other_client = create(:user, :client)
      token = create(:doorkeeper_access_token, resource_owner_id: other_client.id)
      patch "/api/v1/contracts/#{contract.id}", params: {
        contract: { status: 'completed' }
      }.to_json, headers: {
        'Authorization' => "Bearer #{token.token}",
        'Content-Type' => 'application/json'
      }

      expect(response).to have_http_status(:unauthorized)
      puts response.body
      expect(json_response['errors']).to include("Unauthorized to update this contract.")
    end
  end

  describe 'GET /api/v1/contracts/completed' do
    let!(:completed_contract) { create(:contract, project: project, client: client, freelancer: freelancer, status: :completed) }

    it 'returns completed contracts for client' do
      get "/api/v1/contracts/completed", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.first['contract']['status']).to eq('completed')
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
