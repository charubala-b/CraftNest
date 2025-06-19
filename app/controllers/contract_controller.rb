class ContractController < ApplicationController
  # before_action :authenticate_user!

  def new
    @contract = Contract.new(
      project_id: params[:project_id],
      freelancer_id: params[:freelancer_id],
      client_id: current_user.id
    )
  end

  def create
    @contract = Contract.new(contract_params.merge(client_id: current_user.id, status: :inprogress))
    if @contract.save
      redirect_to dashboard_path, notice: 'Contract created!'
    else
      render :new
    end
  end

  def update
    @contract = Contract.find(params[:id])
    if @contract.update(contract_params)
      redirect_to dashboard_path, notice: 'Contract updated.'
    else
      redirect_to dashboard_path, alert: 'Update failed.'
    end
  end

  def index
    @contracts = current_user.contracts_as_client
  end

  private

  def contract_params
    params.require(:contract).permit(:project_id, :freelancer_id, :start_date, :end_date, :status)
  end
end
