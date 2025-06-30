ActiveAdmin.register Project do
  permit_params :title, :description, :client_id

  includes :client

  scope :all, default: true
  scope("Created Today") { |projects| projects.where(created_at: Time.zone.today.all_day) }
  scope("Created This Week") { |projects| projects.where("created_at >= ?", 7.days.ago) }
  scope("Without Any Bids") { |projects| projects.left_joins(:bids).where(bids: { id: nil }) }

  index do
    selectable_column
    id_column
    column :title
    column :description
    column("Client") { |project| project.client.name }
    column :created_at
    actions
  end

  filter :title_cont, as: :string, label: "Project Title Contains"
  filter :client_id,
       as: :select,
       label: "Client",
       collection: -> { User.where(role: :client).pluck(:name, :id) }
  filter :created_at

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :client, collection: User.where(role: :client)
    end
    f.actions
  end
end
