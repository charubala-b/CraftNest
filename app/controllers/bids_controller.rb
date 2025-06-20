class BidsController < ApplicationController
  # before_action :authenticate_user!  # optional, if using Devise or a manual auth check

  def accept
    bid = Bid.find_by(id: params[:id])
    return redirect_to dashboard_path, alert: "Bid not found." unless bid

    project = bid.project

    # Ensure current user is the client who owns the project
    unless project.client_id == current_user.id
      return redirect_to dashboard_path, alert: "Unauthorized action."
    end

    ActiveRecord::Base.transaction do
      # Mark this bid as accepted
      bid.update!(accepted: true)
      Contract.create!(
        project: project,
        client: current_user,
        freelancer: bid.user,
        status: :inprogress,
        start_date: Time.current 
      )
    end

    redirect_to dashboard_path, notice: "Bid accepted and contract created."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_path, alert: "Failed to accept bid: #{e.message}"
  end
end
