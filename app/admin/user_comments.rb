ActiveAdmin.register Comment, as: "UserComment" do
  actions :index, :show, :destroy

  permit_params :user_id, :project_id, :body, :parent_id

  scope :all, default: true
  scope("Top Level") { |comments| comments.where(parent_id: nil) }

  filter :user
  filter :project
  filter :created_at
  filter :body

  index title: "User Comments" do
    selectable_column
    id_column
    column :user
    column :project
    column("Parent Comment") { |comment| comment.parent_id.present? ? "##{comment.parent_id}" : "Top Level" }
    column :body
    column :created_at
    actions
  end
end
