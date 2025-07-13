class Api::V1::ContractsController < Api::V1::BaseController
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  before_action :set_contract, only: [:show, :update]
  before_action :authorize_client!, only: [:create, :update]
  before_action :authorize_access_to_contract!, only: [:show]

  def index
    if current_user.client?
      @contracts = Contract.where(client_id: current_user.id).includes(:project, :freelancer, :client)
    elsif current_user.freelancer?
      @contracts = Contract.where(freelancer_id: current_user.id).includes(:project, :freelancer, :client)
    else
      @contracts = []
    end
    render :index
  end

  def show
    render :show
  end

  def create
    @contract = Contract.new(contract_params.merge(client_id: current_user.id, status: :active))

    if @contract.save
      render :show, status: :created
    else
      render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    unless @contract.status == 'active'
      return render json: { error: "Only active contracts can be updated." }, status: :forbidden
    end

    if @contract.client_id != current_user.id
      return render json: { error: "Unauthorized to update this contract." }, status: :unauthorized
    end

    begin
      if @contract.update(contract_params)
        render :show, status: :ok
      end
    rescue ArgumentError => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end
  end

  def completed
    if current_user.client?
      @contracts = Contract.includes(:project, :freelancer)
                           .where(client_id: current_user.id, status: :completed)
    elsif current_user.freelancer?
      @contracts = Contract.includes(:project, :client)
                           .where(freelancer_id: current_user.id, status: :completed)
    else
      @contracts = []
    end

    render :completed
  end

  private

  def set_contract
    @contract = Contract.includes(:project, :freelancer, :client).find_by(id: params[:id])
    render json: { error: 'Contract not found' }, status: :not_found unless @contract
  end

  def contract_params
    params.require(:contract).permit(:project_id, :freelancer_id, :status)
  end

  def authorize_client!
    unless current_user&.client?
      render json: { error: "Only clients can perform this action." }, status: :forbidden
    end
  end

  def authorize_access_to_contract!
    return if @contract.client_id == current_user.id || @contract.freelancer_id == current_user.id

    render json: { error: "You are not authorized to view this contract." }, status: :unauthorized
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
