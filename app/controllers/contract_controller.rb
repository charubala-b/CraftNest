def update
  @contract = Contract.find(params[:id])
  if @contract.update(contract_params)
    redirect_to dashboard_path, notice: "Contract updated"
  else
    redirect_to dashboard_path, alert: "Failed to update contract"
  end
end

private

def contract_params
  params.require(:contract).permit(:status)
end
