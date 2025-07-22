class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :create, :edit, :update, :destroy ]
  before_action :set_bid, only: [ :edit, :update, :destroy ]
  before_action :authorize_client!, only: [ :accept ]

  def accept
    @bid = Bid.find_by(id: params[:id])
    return redirect_to dashboard_path, alert: "Bid not found." unless @bid

    @bid.update!(accepted: true)

    redirect_to dashboard_path, notice: "Bid accepted and contract created."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_path, alert: "Failed to accept bid: #{e.message}"
  end

  def create
    @bid = @project.bids.build(bid_params)
    @bid.user = current_user
    @bid.accepted = false

    if @bid.save
      flash[:notice] = "Bid submitted successfully"
      redirect_to current_user.freelancer? ? freelancer_dashboard_path : dashboard_path
    else
      flash[:alert] = @bid.errors.full_messages.join(", ")
      redirect_back fallback_location: root_path
    end
  end

  def edit; end

  def update
    if @bid.update(bid_params)
      redirect_to freelancer_dashboard_path, notice: "Bid updated successfully."
    else
      flash[:alert] = "Failed to update bid"
      render :edit
    end
  end

def destroy
  if current_user.freelancer?
    if @bid.user_id != current_user.id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    elsif @bid.accepted?
      render json: { error: "You can't delete an accepted bid." }, status: :forbidden
    else
      @bid.destroy
      render json: { message: "Bid deleted successfully." }, status: :ok
    end
  else
    render json: { error: "Only freelancers can delete bids." }, status: :forbidden
  end
end


  private

  def bid_params
    params.require(:bid).permit(:cover_letter, :proposed_price)
  end

  def set_project
    @project = Project.find_by(id: params[:project_id])
    redirect_to root_path, alert: "Project not found." unless @project
  end

  def set_bid
    @bid = @project.bids.find_by(id: params[:id])
    redirect_to freelancer_dashboard_path, alert: "Bid not found." unless @bid
  end

  def authorize_client!
    bid = Bid.find_by(id: params[:id])
    unless bid && bid.project.client_id == current_user.id
      redirect_to dashboard_path, alert: "Unauthorized action."
    end
  end
end
