require 'rails_helper'

RSpec.describe "API::V1::Bids", type: :request do
  let!(:client) { create(:user, role: :client) }
  let!(:freelancer) { create(:user, role: :freelancer) }
  let!(:project) { create(:project, client: client) }
  let!(:bid) { create(:bid, project: project, user: freelancer) }

  let!(:oauth_app) { Doorkeeper::Application.create!(name: "Test App", redirect_uri: "https://example.com") }

  let(:client_token) do
    Doorkeeper::AccessToken.create!(
      resource_owner_id: client.id,
      application_id: oauth_app.id,
      expires_in: 1.hour,
      scopes: 'public'
    ).token
  end

  let(:freelancer_token) do
    Doorkeeper::AccessToken.create!(
      resource_owner_id: freelancer.id,
      application_id: oauth_app.id,
      expires_in: 1.hour,
      scopes: 'public'
    ).token
  end

  let(:client_headers) { { "Authorization" => "Bearer #{client_token}" } }
  let(:freelancer_headers) { { "Authorization" => "Bearer #{freelancer_token}" } }

  def auth_headers(user)
  token = Doorkeeper::AccessToken.create!(
    resource_owner_id: user.id,
    application_id: oauth_app.id,
    expires_in: 1.hour,
    scopes: 'public'
  ).token
  { "Authorization" => "Bearer #{token}" }
end


  describe "GET /api/v1/bids" do
    context "as a freelancer" do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer) }

      it "returns freelancer's bids" do
        get "/api/v1/bids", headers: freelancer_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "as a client" do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(client) }

      it "returns bids for client's projects" do
        get "/api/v1/bids", headers: client_headers
        expect(response).to have_http_status(:ok)
      end
    end
    context "when user has no role" do
      let(:user) { create(:user, role: nil) }

      it "returns an empty array" do
        get "/api/v1/bids", headers: auth_headers(user)
      aggregate_failures "create with no role" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq([])
      end
      end
    end

  end

  describe "GET /api/v1/bids/:id" do
    context "as authorized freelancer" do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer) }

      it "shows the bid" do
        get "/api/v1/bids/#{bid.id}", headers: freelancer_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "as unauthorized client" do
      let(:other_client) { create(:user, role: :client) }
      let(:other_token) do
        Doorkeeper::AccessToken.create!(
          resource_owner_id: other_client.id,
          application_id: oauth_app.id,
          expires_in: 1.hour,
          scopes: 'public'
        ).token
      end

      before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(other_client) }

      it "returns unauthorized" do
        get "/api/v1/bids/#{bid.id}", headers: { "Authorization" => "Bearer #{other_token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "when client tries to view bid not for their project" do
      let(:client) { create(:user, :client) }
      let(:other_client) { create(:user, :client) }
      let(:project) { create(:project, client: other_client) }
      let(:bid) { create(:bid, project: project) }

      it "returns unauthorized access" do
        get "/api/v1/bids/#{bid.id}", headers: auth_headers(client)
        aggregate_failures "unauthorized user access" do
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["error"]).to eq("Unauthorized access.")
        end
      end
    end

  end

 describe "POST /api/v1/projects/:project_id/bids" do
  let!(:another_freelancer) { create(:user, role: :freelancer) }
  let(:another_freelancer_token) do
    Doorkeeper::AccessToken.create!(
      resource_owner_id: another_freelancer.id,
      application_id: oauth_app.id,
      expires_in: 1.hour,
      scopes: 'public'
    ).token
  end
  let(:headers) do
    {
      "Authorization" => "Bearer #{another_freelancer_token}",
      "Content-Type" => "application/json"
    }
  end

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(another_freelancer)
  end

  it "creates a bid" do
    post "/api/v1/projects/#{project.id}/bids",
         params: {
           bid: {
             cover_letter: "https://github.com/charubala-b/CraftNest",
             proposed_price: 150.0
           }
         }.to_json,
         headers: headers

    body = JSON.parse(response.body)

    aggregate_failures "bid creation response" do
      expect(body["bid"]["cover_letter"]).to eq("https://github.com/charubala-b/CraftNest")
      expect(body["bid"]["proposed_price"]).to eq("150.0")
      expect(body["bid"]["project"]["id"]).to eq(project.id)
      expect(body["bid"]["user"]["id"]).to eq(another_freelancer.id)
    end
  end

  context "when bid creation fails due to missing fields" do
    let(:freelancer) { create(:user, :freelancer) }
    let(:project) { create(:project) }

    it "returns unprocessable_entity" do
      post "/api/v1/projects/#{project.id}/bids",
          params: { bid: { cover_letter: "" } },
          headers: auth_headers(freelancer)
    aggregate_failures "unprocessable cover letter blank" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to include("Cover letter can't be blank")
    end
    end
  end

  context "when bid creation fails due to validation errors" do
  let(:freelancer) { create(:user, :freelancer) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
  end

  it "returns unprocessable_entity" do
    post "/api/v1/projects/#{project.id}/bids",
         params: { bid: { cover_letter: "", proposed_price: nil } },
         headers: auth_headers(freelancer)
    aggregate_failures "unprocessable validations" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to include("Cover letter can't be blank")
    end
  end
end



end

  describe "PATCH /api/v1/bids/:id" do
    before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer) }

    it "updates the bid" do
      patch "/api/v1/bids/#{bid.id}", params: {
        bid: { proposed_price: 999 }
      }, headers: freelancer_headers

      aggregate_failures "bid update response" do
        expect(response).to have_http_status(:ok)
        expect(bid.reload.proposed_price).to eq(999)
      end
    end
      context "when freelancer tries to update someone else's bid" do
  let(:freelancer) { create(:user, :freelancer) }
  let(:other_bid) { create(:bid) }

  it "returns unauthorized action" do
    patch "/api/v1/bids/#{other_bid.id}",
          params: { bid: { proposed_price: 1000 } },
          headers: auth_headers(freelancer)
  aggregate_failures "unauthorized update" do
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("Unauthorized action.")
  end
  end
end

context "when freelancer tries to update someone else's bid" do
  let(:freelancer) { create(:user, :freelancer) }
  let(:bid) { create(:bid) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
  end

  it "returns unauthorized" do
    patch "/api/v1/bids/#{bid.id}", params: { bid: { proposed_price: 900 } }, headers: auth_headers(freelancer)
    aggregate_failures "unauthorized user update" do
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Unauthorized action.")
    end
  end
end

context "when update fails due to validation error" do
  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
  end

  it "returns unprocessable_entity" do
    patch "/api/v1/bids/#{bid.id}", params: { bid: { proposed_price: nil } }, headers: auth_headers(freelancer)
    aggregate_failures "unprocessable validations" do
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["errors"]).to include("Proposed price can't be blank")
    end
  end
end

  end

  describe "DELETE /api/v1/bids/:id" do
    context "when bid is not accepted" do
      let!(:deletable_bid) { create(:bid, project: project, user: freelancer, accepted: false) }

      before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer) }

      it "deletes the bid" do
        expect {
          delete "/api/v1/bids/#{deletable_bid.id}", headers: freelancer_headers
        }.to change(Bid, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when bid is accepted" do
      before do
        bid.update!(accepted: true)
        allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
      end

      it "returns forbidden" do
        delete "/api/v1/bids/#{bid.id}", headers: freelancer_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
context "when client tries to delete a bid" do
  let(:client) { create(:user, role: :client) }
  let(:bid) { create(:bid) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(client)
  end

  it "returns forbidden (only freelancers can perform this action)" do
    delete "/api/v1/bids/#{bid.id}", headers: auth_headers(client)
    aggregate_failures "forbidden to perform action" do
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body["error"]).to eq("Only freelancers can perform this action.")
    end
  end
end



context "when freelancer tries to delete an accepted bid" do
  let(:freelancer) { create(:user, :freelancer) }
  let(:bid) { create(:bid, user: freelancer, accepted: true) }

  it "returns forbidden" do
    delete "/api/v1/bids/#{bid.id}", headers: auth_headers(freelancer)
    aggregate_failures "forbidden delete" do
      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("You can't delete an accepted bid.")
    end
  end
end

context "when freelancer tries to delete another freelancer's bid" do
  let(:freelancer) { create(:user, :freelancer) }
  let(:other_bid) { create(:bid) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
  end

  it "returns unauthorized" do
    delete "/api/v1/bids/#{other_bid.id}", headers: auth_headers(freelancer)
    aggregate_failures "unauthorized action" do
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Unauthorized action.")
    end
  end
end

context "when freelancer tries to delete an accepted bid" do
  let(:freelancer) { create(:user, :freelancer) }
  let(:bid) { create(:bid, user: freelancer, accepted: true) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
  end

  it "returns forbidden" do
    delete "/api/v1/bids/#{bid.id}", headers: auth_headers(freelancer)
    aggregate_failures "forbidden delete" do
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body["error"]).to eq("You can't delete an accepted bid.")
    end
  end
end
context "when user with no role tries to delete a bid" do
  let(:user) { create(:user, role: nil) }
  let(:bid) { create(:bid) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  it "returns forbidden" do
    delete "/api/v1/bids/#{bid.id}", headers: auth_headers(user)
    aggregate_failures "forbidden user action" do
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body["error"]).to eq("Only freelancers can perform this action.")
    end
  end
end


  end

  describe "POST /api/v1/bids/:id/accept" do
    before { allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(client) }

    it "accepts the bid" do
      post "/api/v1/bids/#{bid.id}/accept", headers: client_headers

      aggregate_failures "bid acceptance" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Bid accepted successfully.")
        expect(bid.reload.accepted).to be(true)
      end
    end
    context "when accepting bid fails due to invalid update" do
  let(:client) { create(:user, :client) }
  let(:bid) { create(:bid, project: create(:project, client: client)) }

  before do
    allow_any_instance_of(Bid).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(bid))
  end

  it "returns unprocessable_entity" do
    post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(client)
    aggregate_failures "failed to accept" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to match(/Failed to accept bid/)
    end
  end
end
context "when non-freelancer tries to create a bid" do
  let(:client) { create(:user, :client) }
  let(:project) { create(:project) }

  it "returns forbidden" do
    post "/api/v1/projects/#{project.id}/bids", headers: auth_headers(client)
    aggregate_failures "forbidden action" do
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body["error"]).to eq("Only freelancers can perform this action.")
    end
  end
end

context "when non-client tries to accept a bid" do
  let(:freelancer) { create(:user, :freelancer) }
  let(:bid) { create(:bid) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(freelancer)
  end

  it "returns forbidden" do
    post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(freelancer)
    aggregate_failures "forbidden action" do
    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body["error"]).to eq("Only clients can perform this action.")
    end
  end
end
context "when client tries to accept a bid not belonging to their project" do
  let(:other_client) { create(:user, :client) }
  let(:project) { create(:project) }
  let(:bid) { create(:bid, project: project) }

  before do
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(other_client)
  end

  it "returns unauthorized action" do
    post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(other_client)
    aggregate_failures "unauthorized action" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Unauthorized action.")
    end
  end
end



  end
end
