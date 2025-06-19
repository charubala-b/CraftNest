class BidsController < ApplicationController
  def accept
  bid = Bid.find(params[:id])
  project = bid.project

  # Create a contract
  Contract.create!(
    project: project,
    client: current_user,
    freelancer: bid.user,
    status: :inprogress,
    start_date: Time.now
  )

  # Cancel other bids
  project.bids.where.not(id: bid.id).destroy_all

  redirect_to dashboard_path, notice: "Bid accepted and contract created."
end

end
