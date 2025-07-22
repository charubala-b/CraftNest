ActiveAdmin.register Bid do
  actions :index, :show, :destroy

  permit_params :user_id, :project_id, :proposed_price, :cover_letter, :accepted

  scope :all, default: true
  scope("Accepted") { |bids| bids.where(accepted: true) }
  scope("Pending") { |bids| bids.where(accepted: [ false, nil ]) }

  filter :user
  filter :project
  filter :accepted
  filter :created_at


  filter :price_above_100, as: :boolean, label: "Price > 100?"


  member_action :mark_accepted, method: :put do
    resource.update(accepted: true)
    redirect_to resource_path, notice: "Bid marked as accepted."
  end

  action_item :mark_accepted, only: :show do
    link_to "Mark as Accepted", mark_accepted_admin_bid_path(resource), method: :put if !resource.accepted?
  end
end
