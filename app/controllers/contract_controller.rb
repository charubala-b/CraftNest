class ContractController < ApplicationController
  def update
    @contract = Contract.find(params[:id])
    if @contract.update(contract_params)
      redirect_to dashboard_path, notice: "Contract marked as completed."
    else
      redirect_to dashboard_path, alert: "Failed to update contract."
    end
  end

  def create
    @contract = Contract.new(contract_params.merge(client_id: current_user.id, status: :active))
    if @contract.save
      redirect_to dashboard_path, notice: 'Contract created!'
    else
      render :new
    end
  end

  private

  def contract_params
    params.require(:contract).permit(:status)
  end
end
