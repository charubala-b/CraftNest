class Api::V1::BidsController < Api::V1::BaseController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :set_project, only: [:create]
  before_action :set_bid, only: [:update, :destroy, :accept, :show]
  before_action :authorize_freelancer!, only: [:update, :destroy]
  before_action :authorize_client!, only: [:accept]

  def index
    @bids = Bid.includes(:user, :project).all
    render :index
  end

  def show
    render :show
  end

  def create
    @bid = @project.bids.build(bid_params.merge(user: current_user, accepted: false))

    if @bid.save
      render :show, status: :created
    else
      render json: { errors: @bid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @bid.update(bid_params)
      render :show, status: :ok
    else
      render json: { errors: @bid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @bid.accepted?
      render json: { error: "You can't delete an accepted bid." }, status: :forbidden
    else
      @bid.destroy
      render json: { message: "Bid deleted successfully." }, status: :ok
    end
  end

  def accept
    ActiveRecord::Base.transaction do
      @bid.update!(accepted: true)
      # Optional: Create contract here if needed
    end
    render json: { message: "Bid accepted successfully." }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Failed to accept bid: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def bid_params
    params.require(:bid).permit(:cover_letter, :proposed_price)
  end

  def set_project
    @project = Project.find_by(id: params[:project_id])
    render json: { error: "Project not found." }, status: :not_found unless @project
  end

  def set_bid
    @bid = Bid.find_by(id: params[:id])
    render json: { error: "Bid not found." }, status: :not_found unless @bid
  end

  def authorize_freelancer!
    unless @bid.user_id == current_user.id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    end
  end

  def authorize_client!
    unless @bid.project.client_id == current_user.id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    end
  end
end
