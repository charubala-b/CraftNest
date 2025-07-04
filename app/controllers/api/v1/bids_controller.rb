class Api::V1::BidsController < Api::V1::BaseController
  before_action :set_bid, only: [:show, :update, :destroy, :accept]
  before_action :set_project, only: [:create]
  before_action :authorize_freelancer!, only: [:create, :update, :destroy]
  before_action :authorize_client!, only: [:accept]

  # GET /api/v1/bids
  def index
    if current_user.client?
      project_ids = current_user.projects.pluck(:id)
      @bids = Bid.includes(:user, :project).where(project_id: project_ids)
    elsif current_user.freelancer?
      @bids = current_user.bids.includes(:project)
    else
      @bids = []
    end

    render :index
  end

  # GET /api/v1/bids/:id
  def show
    if current_user.client? && @bid.project.client_id != current_user.id
      render json: { error: "Unauthorized access." }, status: :unauthorized
    elsif current_user.freelancer? && @bid.user_id != current_user.id
      render json: { error: "Unauthorized access." }, status: :unauthorized
    else
      render :show
    end
  end

  # POST /api/v1/projects/:project_id/bids
  def create
    @bid = @project.bids.build(bid_params.merge(user: current_user, accepted: false))

    if @bid.save
      render :show, status: :created
    else
      render json: { errors: @bid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/bids/:id
  def update
    if @bid.user_id != current_user.id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    elsif @bid.update(bid_params)
      render :show, status: :ok
    else
      render json: { errors: @bid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/bids/:id
def destroy
  if current_user.freelancer?
    if @bid.user_id != current_user.id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    elsif @bid.accepted?
      render json: { error: "You can't delete an accepted bid." }, status: :forbidden
    else
      @bid.destroy
      head :no_content
    end
  else
    render json: { error: "Only freelancers can delete bids." }, status: :forbidden
  end
end


  # POST /api/v1/bids/:id/accept
  def accept
    if @bid.project.client_id != current_user.id
      render json: { error: "Unauthorized action." }, status: :unauthorized
    else
      ActiveRecord::Base.transaction do
        @bid.update!(accepted: true)
      end
      render json: { message: "Bid accepted successfully." }, status: :ok
    end
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
    unless current_user.freelancer?
      render json: { error: "Only freelancers can perform this action." }, status: :forbidden
    end
  end

  def authorize_client!
    unless current_user.client?
      render json: { error: "Only clients can perform this action." }, status: :forbidden
    end
  end
end
