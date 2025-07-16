class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_freelancer
  before_action :authorize_client_or_freelancer!

  def show
  @freelancer = User.find_by(id: params[:id])

  unless @freelancer
    redirect_to root_path, alert: "Freelancer not found" and return
  end

  @total_bids = @freelancer.bids.count
  @accepted_bids = @freelancer.bids.accepted.count
  @bid_win_rate = @total_bids.positive? ? ((@accepted_bids.to_f / @total_bids) * 100).round(2) : 0
  @average_rating = @freelancer.reviews_received.average(:ratings)&.round(2) || 0

@revenue_over_time = @freelancer.contracts_as_freelancer
  .includes(:project)
  .each_with_object(Hash.new(0)) do |contract, hash|
    bid = Bid.find_by(project_id: contract.project_id, user_id: contract.freelancer_id, accepted: true)
    if bid
      month_label = contract.created_at.strftime("%b %Y")
      hash[month_label] += bid.proposed_price.to_f
    end
  end


  @most_requested_skills = Skill
    .joins(:projects)
    .group(:skill_name)
    .order("count_all DESC")
    .limit(5)
    .count
end


  private

  def set_freelancer
    @freelancer = User.find(params[:id])
if @freelancer.nil?
  Rails.logger.debug "No freelancer found with that ID"
  redirect_to root_path, alert: "Freelancer not found" and return
end

  end

  def authorize_client_or_freelancer!
    unless current_user == @freelancer || current_user.client?
      render plain: "Unauthorized", status: :unauthorized
    end
  end
end
