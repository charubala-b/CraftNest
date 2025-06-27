# app/admin/user_comments.rb
ActiveAdmin.register Comment, as: "UserComment" do

  actions :index, :show, :destroy

  permit_params :user_id, :project_id, :body, :parent_id

  scope :all, default: true
  scope("Top Level") { |c| c.where(parent_id: nil) }

  filter :user
  filter :project
  filter :created_at
  filter :body
end
