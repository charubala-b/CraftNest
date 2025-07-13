require 'rails_helper'

RSpec.describe "API::V1::Contracts", type: :request do
  let!(:client)     { create(:user, role: :client) }
  let!(:freelancer) { create(:user, role: :freelancer) }
  let!(:project)    { create(:project, client: client) }
  let!(:contract)   { create(:contract, project: project, client: client, freelancer: freelancer) }

  let(:client_token)     { create(:access_token, resource_owner_id: client.id) }
  let(:freelancer_token) { create(:access_token, resource_owner_id: freelancer.id) }

  let(:client_headers)     { { "Authorization" => "Bearer #{client_token.token}" } }
  let(:freelancer_headers) { { "Authorization" => "Bearer #{freelancer_token.token}" } }

  def auth_headers(user)
    token = Doorkeeper::AccessToken.create!(
      application_id: Doorkeeper::Application.create!(name: "Test App", redirect_uri: "https://example.com").id,
      resource_owner_id: user.id,
      scopes: 'public'
    ).token
    { "Authorization" => "Bearer #{token}" }
  end


  let(:contracts_path)           { "/api/v1/contracts" }
  let(:contract_path)            { ->(id) { "/api/v1/contracts/#{id}" } }
  let(:completed_contracts_path) { "/api/v1/contracts/completed" }

  describe "GET /api/v1/contracts" do
    it "returns contracts for client" do
      get contracts_path, headers: client_headers
      aggregate_failures "client index" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to be_empty
      end
    end

    it "returns contracts for freelancer" do
      get contracts_path, headers: freelancer_headers
      aggregate_failures "freelancer index" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to be_empty
      end
    end

    context "when user is neither client nor freelancer" do
      let(:random_user) { create(:user, role: nil) }

      it "returns empty contracts list for index" do
        get contracts_path, headers: auth_headers(random_user)
        aggregate_failures "index for random user" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq([])
        end
      end

      it "returns empty contracts list for completed" do
        get completed_contracts_path, headers: auth_headers(random_user)
        aggregate_failures "completed for random user" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to eq([])
        end
      end
    end
  end

  describe "GET /api/v1/contracts/:id" do
    it "returns contract if authorized (client)" do
      get contract_path.call(contract.id), headers: client_headers
      expect(response).to have_http_status(:ok)
    end

    it "returns contract if authorized (freelancer)" do
      get contract_path.call(contract.id), headers: freelancer_headers
      expect(response).to have_http_status(:ok)
    end

    it "returns unauthorized for unrelated user" do
      outsider = create(:user)
      token = create(:access_token, resource_owner_id: outsider.id)
      get contract_path.call(contract.id), headers: { "Authorization" => "Bearer #{token.token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/contracts" do
    let(:valid_params) do
      {
        contract: {
          project_id: project.id,
          freelancer_id: freelancer.id,
          status: 'active'
        }
      }
    end

    it "creates a contract for client" do
      new_freelancer = create(:user, role: :freelancer)

      post contracts_path, params: {
        contract: {
          project_id: project.id,
          freelancer_id: new_freelancer.id,
          status: 'active'
        }
      }, headers: client_headers

      aggregate_failures "create contract" do
        expect(response).to have_http_status(:created)
        expect(response.parsed_body["contract"]["status"]).to eq("active")
      end
    end

    it "forbids freelancers from creating contracts" do
      post contracts_path, params: valid_params, headers: freelancer_headers
      expect(response).to have_http_status(:forbidden)
    end

    context "when contract creation fails due to validation" do
      it "returns unprocessable_entity" do
        post contracts_path, params: {
          contract: { project_id: nil, freelancer_id: nil }
        }, headers: auth_headers(client)

        aggregate_failures "contract validation error" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("Project must exist", "Freelancer must exist")
        end
      end
    end
    context "when contract param is missing" do
  it "returns 400 bad request with error message" do
    post contracts_path,
         params: {}.to_json,
         headers: client_headers.merge("CONTENT_TYPE" => "application/json")

    aggregate_failures "missing param" do
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to match("param is missing or the value is empty: contract")
    end
  end
end

  end

  describe "PATCH /api/v1/contracts/:id" do
    it "updates contract if client and status is active" do
      patch contract_path.call(contract.id), params: {
        contract: { status: "completed" }
      }, headers: client_headers

      aggregate_failures "update to completed" do
        expect(response).to have_http_status(:ok)
        expect(contract.reload.status).to eq("completed")
      end
    end

    it "does not allow update if status is not active" do
      contract.update!(status: "completed")
      patch contract_path.call(contract.id), params: {
        contract: { status: "active" }
      }, headers: client_headers

      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow freelancer to update contract" do
      patch contract_path.call(contract.id), params: {
        contract: { status: "completed" }
      }, headers: freelancer_headers

      expect(response).to have_http_status(:forbidden)
    end

    context "when another client tries to update contract" do
      let(:other_client) { create(:user, :client) }
      let!(:contract) { create(:contract, client: client, freelancer: freelancer, project: project) }

      it "returns unauthorized" do
        patch contract_path.call(contract.id), params: {
          contract: { status: :completed }
        }, headers: auth_headers(other_client)

        aggregate_failures "unauthorized update" do
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["error"]).to eq("Unauthorized to update this contract.")
        end
      end
    end

    context "when update fails due to invalid status" do
      let!(:contract) { create(:contract, client: client, freelancer: freelancer, project: project) }

      it "returns unprocessable_entity" do
        patch contract_path.call(contract.id), params: {
          contract: { status: "invalid_status" }
        }, headers: auth_headers(client)

        aggregate_failures "invalid status" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("'invalid_status' is not a valid status")
        end
      end
    end
  end

  describe "GET /api/v1/contracts/completed" do
    before { contract.update!(status: "completed") }

    it "returns completed contracts for client" do
      get completed_contracts_path, headers: client_headers
      aggregate_failures "completed for client" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to be_empty
      end
    end

    it "returns completed contracts for freelancer" do
      get completed_contracts_path, headers: freelancer_headers
      aggregate_failures "completed for freelancer" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to be_empty
      end
    end
  end
end
