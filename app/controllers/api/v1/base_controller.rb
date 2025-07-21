module Api
  module V1
    class BaseController < ApplicationController
      before_action :doorkeeper_authorize!
      private

      def authorize_freelancer!
        unless current_user_api&.freelancer?
          render json: { error: "Forbidden: Only freelancers can perform this action." }, status: :forbidden
        end
      end

      def authorize_client!
        unless current_user_api&.client?
          render json: { error: "Forbidden: Only clients can perform this action." }, status: :forbidden
        end
      end

      def authorize_access_to_contract!(contract = @contract)
        unless contract.client_id == current_user_api&.id || contract.freelancer_id == current_user_api&.id
          render json: { error: 'You are not authorized to view this contract.' }, status: :unauthorized
        end
      end
      
    end
  end
end
