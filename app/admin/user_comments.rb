ActiveAdmin.register Comment, as: "UserComment" do
  actions :index, :show, :destroy

  permit_params :user_id, :project_id, :body, :parent_id

  scope :all, default: true
  scope("Top Level") { |comments| comments.where(parent_id: nil) }

  filter :user, as: :select, collection: -> { User.all.map { |u| [u.name, u.id] } }
  filter :project, as: :select, collection: -> { Project.all.map { |p| [p.title, p.id] } }
  filter :created_at, as: :date_range
  filter :body, as: :string

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
