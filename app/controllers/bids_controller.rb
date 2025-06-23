class BidsController < ApplicationController

  def accept
    bid = Bid.find_by(id: params[:id])
    return redirect_to dashboard_path, alert: "Bid not found." unless bid

    project = bid.project

    unless project.client_id == current_user.id
      return redirect_to dashboard_path, alert: "Unauthorized action."
    end

    ActiveRecord::Base.transaction do
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

 def create
  @project = Project.find(params[:project_id])
  @bid = @project.bids.build(bid_params)
  @bid.user = current_user           # ensure the current freelancer is attached
  @bid.accepted = false              # set default value

  if @bid.save
    flash[:notice] = "Bid submitted successfully"
    if current_user.freelancer?
      redirect_to freelancer_dashboard_path
    else
      redirect_to dashboard_path
    end
  else
    flash[:alert] = "Failed to submit bid"
    redirect_back fallback_location: root_path
  end
end

def edit
  @project = Project.find(params[:project_id])
  @bid = @project.bids.find(params[:id])
end

def update
  @project = Project.find(params[:project_id])
  @bid = @project.bids.find(params[:id])

  if @bid.update(bid_params)
    redirect_to freelancer_dashboard_path, notice: "Bid updated successfully."
  else
    flash[:alert] = "Failed to update bid"
    render :edit
  end
end

def destroy
  @project = Project.find(params[:project_id])
  @bid = @project.bids.find(params[:id])
  @bid.destroy
  redirect_to freelancer_dashboard_path, notice: "Bid deleted successfully."
end



private

def bid_params
  params.require(:bid).permit(:cover_letter, :proposed_price)
end


end
