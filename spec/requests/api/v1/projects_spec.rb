require 'rails_helper'

RSpec.describe 'API::V1::Projects', type: :request do
  let(:client)     { create(:user, role: :client) }
  let(:freelancer) { create(:user, role: :freelancer) }

  let(:client_token)     { create(:access_token, resource_owner_id: client.id) }
  let(:freelancer_token) { create(:access_token, resource_owner_id: freelancer.id) }

  let(:client_headers)     { { "Authorization" => "Bearer #{client_token.token}" } }
  let(:freelancer_headers) { { "Authorization" => "Bearer #{freelancer_token.token}" } }

  def auth_headers(user)
    app = Doorkeeper::Application.create!(name: "Test App", redirect_uri: "https://example.com")
    token = Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: user.id, scopes: 'public').token
    { "Authorization" => "Bearer #{token}" }
  end

  let(:projects_path)  { "/api/v1/projects" }
  let(:project_path)   { ->(id) { "/api/v1/projects/#{id}" } }

  describe 'GET /api/v1/projects' do
    before do
      create_list(:project, 3, client: client)
      create(:project, title: "Other Project #{SecureRandom.hex(3)}")
    end

    it 'returns only client projects for client user' do
      get projects_path, headers: client_headers
      aggregate_failures "client project list" do
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(3)
      end
    end

    it 'returns all projects for freelancer user' do
      get projects_path, headers: freelancer_headers
      aggregate_failures "freelancer project list" do
        expect(response).to have_http_status(:ok)
        expect(json.size).to be >= 4
      end
    end

    it 'returns empty array if no user and no application' do
      get projects_path
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end

  describe 'GET /api/v1/projects/:id' do
    let!(:project) { create(:project, client: client, title: "Valid Title for Show") }

    it 'shows project if client owns it' do
      get project_path.call(project.id), headers: client_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized if client does not own the project' do
      other_project = create(:project)
      get project_path.call(other_project.id), headers: client_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_params) do
      {
        project: {
          title: "A Valid Project Title Here",
          description: "Some detailed description of the project.",
          budget: 500,
          deadline: 5.days.from_now,
          new_skills: "React, NodeJS",
          skill_ids: []
        }
      }
    end

    it 'creates a new project for client' do
      expect {
        post projects_path, params: valid_params, headers: client_headers
      }.to change(Project, :count).by(1)

      aggregate_failures "project creation" do
        expect(response).to have_http_status(:created)
        expect(json["project"]["title"]).to eq("A Valid Project Title Here")
      end
    end

    it 'returns error for negative budget' do
      invalid_params = valid_params.deep_merge(project: { budget: -100 })
      post projects_path, params: invalid_params, headers: client_headers
      aggregate_failures "invalid budget" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to eq("Budget cannot be negative.")
      end
    end

    it 'returns forbidden for freelancer' do
      post projects_path, params: valid_params, headers: freelancer_headers
      expect(response).to have_http_status(:forbidden)
    end

    context "when validation fails" do
      it "returns error messages" do
        post projects_path, params: { project: { title: "", description: "" } }, headers: auth_headers(client)

        aggregate_failures "validation errors" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("Title can't be blank", "Description can't be blank")
        end
      end
    end

    context "when new_skills are provided during project creation" do
  it "creates new skills and associates them" do
    post "/api/v1/projects", params: {
      project: {
        title: "Skill Test Project view",
        description: "Some description about the skill test project view",
        budget: 1000,
        deadline: "2025-12-31"
      },
      new_skills: "react, tailwind"
    }, headers: auth_headers(client)

    expect(response).to have_http_status(:created)
    expect(Project.last.skills.pluck(:skill_name)).to include("react", "tailwind")
  end

end

  end

  describe 'PATCH /api/v1/projects/:id' do
    let!(:project) { create(:project, client: client, title: "Original Title is created") }

    it 'updates project if owned by client' do
      patch project_path.call(project.id), params: { project: { title: "Updated Title is created" } }, headers: client_headers

      aggregate_failures "successful update" do
        expect(response).to have_http_status(:ok)
        expect(json["project"]["title"]).to eq("Updated Title is created")
      end
    end

    it 'returns unauthorized if client is not the owner' do
      other_project = create(:project)
      patch project_path.call(other_project.id), params: { project: { title: "Hack Attempt is solved" } }, headers: client_headers

      expect(response).to have_http_status(:unauthorized)
    end

    context "when title is blank" do
      it "returns validation errors" do
        patch project_path.call(project.id), params: { project: { title: "" } }, headers: auth_headers(client)

        aggregate_failures "title blank" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("Title can't be blank")
        end
      end
    end

    context "when budget is negative" do
      it "rejects the update" do
        patch project_path.call(project.id), params: { project: { budget: -500 } }, headers: auth_headers(client)

        aggregate_failures "negative budget update" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["error"]).to eq("Budget cannot be negative.")
        end
      end
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, client: client) }

    it 'deletes project if owned by client' do
      expect {
        delete project_path.call(project.id), headers: client_headers
      }.to change(Project, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized if not owned by client' do
      other_project = create(:project)
      delete project_path.call(other_project.id), headers: client_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
