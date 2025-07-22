class Api::V1::ContractsController < Api::V1::BaseController
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  before_action :set_contract, only: [ :show, :update ]
  before_action :authorize_client!, only: [ :create, :update ]
  before_action only: [ :show ] do
  authorize_access_to_contract!(@contract)
  end


  def index
    if current_user_api.client?
      @contracts = Contract.where(client_id: current_user_api.id).includes(:project, :freelancer, :client)
    elsif current_user_api.freelancer?
      @contracts = Contract.where(freelancer_id: current_user_api.id).includes(:project, :freelancer, :client)
    else
      @contracts = []
    end
    render :index
  end

  def show
    render :show
  end

  def create
    @contract = Contract.new(contract_params.merge(client_id: current_user_api.id, status: :active))

    if @contract.save
      render :show, status: :created
    else
      render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @contract.status != "active"
      return render json: { errors: [ "Only active contracts can be updated." ] }, status: :forbidden
    end

    if @contract.client_id != current_user_api.id
      return render json: { errors: [ "Unauthorized to update this contract." ] }, status: :unauthorized
    end

    if @contract.update(contract_params)
      render :show, status: :ok
    else
      render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ArgumentError => e
    render json: { errors: [ e.message ] }, status: :unprocessable_entity
  end

  def completed
    if current_user_api.client?
      @contracts = Contract.includes(:project, :freelancer)
                           .where(client_id: current_user_api.id, status: :completed)
    elsif current_user_api.freelancer?
      @contracts = Contract.includes(:project, :client)
                           .where(freelancer_id: current_user_api.id, status: :completed)
    else
      @contracts = []
    end

    render :completed
  end

  private

  def set_contract
    @contract = Contract.includes(:project, :freelancer, :client).find_by(id: params[:id])
    render json: { errors: [ "Contract not found" ] }, status: :not_found unless @contract
  end

  def contract_params
    params.require(:contract).permit(:project_id, :freelancer_id, :status)
  end

  def handle_parameter_missing(exception)
    render json: { errors: [ exception.message ] }, status: :bad_request
  end
end
