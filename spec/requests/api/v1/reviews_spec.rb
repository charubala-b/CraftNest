# spec/requests/api/v1/reviews_spec.rb
require 'rails_helper'

RSpec.describe 'API::V1::Reviews', type: :request do
  include JsonHelpers

  let(:client)     { create(:user, :client) }
  let(:freelancer) { create(:user, :freelancer) }
  let(:project)    { create(:project, client: client) }

  let(:token) do
    create(:doorkeeper_access_token,
           resource_owner_id: client.id,
           scopes: 'read write')
  end

  let(:headers) do
    {
      'Authorization' => "Bearer #{token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  describe 'GET /api/v1/reviews/:project_id' do
    context 'when a review exists' do
      let!(:review) { create(:review, project: project, reviewer: client, reviewee: freelancer) }

      it 'returns the review' do
        get "/api/v1/reviews/#{project.id}", headers: headers

        aggregate_failures 'getting the review' do
          expect(response).to have_http_status(:ok)
          expect(json_response['id']).to eq(review.id)
          expect(json_response['review']).to eq(review.review)
        end
      end
    end

    context 'when no review exists' do
      it 'returns 404 not found' do
        get "/api/v1/reviews/#{project.id}", headers: headers

        aggregate_failures 'validating review' do
          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq('Review not found')
        end
      end
    end
  end

  describe 'POST /api/v1/reviews/:project_id' do
    let!(:contract) { create(:contract, project: project, client: client, freelancer: freelancer) }

    context 'with valid params' do
      let(:valid_params) do
        {
          review: {
            ratings: 5,
            review: 'Excellent work done by you'
          }
        }.to_json
      end

      it 'creates a review successfully' do
        post "/api/v1/reviews/#{project.id}", params: valid_params, headers: headers

        aggregate_failures 'creating review' do
          expect(response).to have_http_status(:created)
          expect(json_response['review']).to eq('Excellent work done by you')
          expect(json_response['ratings']).to eq(5)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          review: {
            ratings: nil,
            review: ''
          }
        }.to_json
      end

      it 'returns 422 unprocessable entity' do
        post "/api/v1/reviews/#{project.id}", params: invalid_params, headers: headers

        aggregate_failures 'validating for 422' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to be_an(Array)
        end
      end
    end
  end
end
