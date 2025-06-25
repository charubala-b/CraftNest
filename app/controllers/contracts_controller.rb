class ContractsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_contract, only: [:update]

  def create
    @contract = Contract.new(contract_params.merge(client_id: current_user.id, status: :active))
    if @contract.save
      flash[:notice] = 'Contract created!'
      redirect_to dashboard_path
    else
      flash[:alert] = 'Failed to create contract.'
      render :new
    end
  end

  def update
    if @contract.update(contract_params)
      flash[:notice] = "Contract marked as completed."
    else
      flash[:alert] = "Failed to update contract."
    end
    redirect_to dashboard_path(anchor: 'contracts')
  end

  private

  def set_contract
    @contract = Contract.find_by(id: params[:id])
    unless @contract
      redirect_to dashboard_path, alert: "Contract not found."
    end
  end

  def contract_params
    params.require(:contract).permit(:status)
  end
end
