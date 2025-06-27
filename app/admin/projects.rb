ActiveAdmin.register Project do
  permit_params :title, :description, :client_id

  includes :client

  index do
    selectable_column
    id_column
    column :title
    column :description
    column("Client") { |project| project.client.name }
    column :created_at
    actions
  end

  filter :title
  filter :client, collection: -> { User.where(role: :client) }
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
