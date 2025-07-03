class Api::V1::ContractsController < Api::V1::BaseController
  before_action :set_contract, only: [:show, :update]

  def index
    @contracts = Contract.includes(:project, :freelancer, :client).all
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
    if @contract.update(contract_params)
      render :show, status: :ok
    else
      render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_contract
    @contract = Contract.includes(:project, :freelancer, :client).find_by(id: params[:id])
    render json: { error: 'Contract not found' }, status: :not_found unless @contract
  end

  def contract_params
    params.require(:contract).permit(:project_id, :freelancer_id, :status)
  end
end
