require 'rails_helper'

RSpec.describe 'API::V1::Projects', type: :request do
  include JsonHelpers

  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }

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

  describe 'GET /api/v1/projects' do
    before do
      create_list(:project, 2, client: client)
    end

    it 'returns projects owned by client' do
      get '/api/v1/projects', headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(2)
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_params) do
      {
        project: {
          title: 'New Freelance Project Title',
          description: 'A test description that meets the minimum length requirement.',
          budget: 1000,
          deadline: 5.days.from_now,
          new_skills: 'Ruby, Rails'
        }
      }.to_json
    end

    context 'with valid parameters' do
      it 'creates a project' do
        post '/api/v1/projects', params: valid_params, headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['project']['title']).to eq('New Freelance Project Title')
      end
    end

    context 'with negative budget' do
      let(:invalid_params) do
        {
          project: {
            title: 'Invalid Budget Project',
            description: 'A short test desc.',
            budget: -500,
            deadline: 5.days.from_now
          }
        }.to_json
      end

      it 'returns 422 with validation error' do
        post '/api/v1/projects', params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Budget must be a non-negative number")
      end
    end

    context 'with missing title/description' do
      let(:invalid_params) do
        {
          project: {
            title: '',
            description: '',
            budget: 1000,
            deadline: 5.days.from_now
          }
        }.to_json
      end

      it 'returns 422 with validation messages' do
        post '/api/v1/projects', params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Title can't be blank", "Description can't be blank")
      end
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    let!(:project) { create(:project, client: client) }

    it 'updates project with valid data' do
      patch "/api/v1/projects/#{project.id}", params: {
        project: { title: 'Updated Project Title' }
      }.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['project']['title']).to eq('Updated Project Title')
    end

    context 'with invalid data' do
      it 'returns validation error for empty title' do
        patch "/api/v1/projects/#{project.id}", params: {
          project: { title: '' }
        }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Title can't be blank")
      end

      it 'returns validation error for negative budget' do
        patch "/api/v1/projects/#{project.id}", params: {
          project: { budget: -100 }
        }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Budget must be a non-negative number")
      end
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, client: client) }

    it 'deletes the project' do
      expect {
        delete "/api/v1/projects/#{project.id}", headers: headers
      }.to change(Project, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
