ActiveAdmin.register Message do
  permit_params :sender_id, :receiver_id, :content

  includes :sender, :receiver

  index do
    selectable_column
    id_column
    column("Sender") { |m| m.sender.email }
    column("Receiver") { |m| m.receiver.email }
    column :content
    column :created_at
    actions
  end

  filter :sender, collection: -> { User.all }
  filter :receiver, collection: -> { User.all }
  filter :created_at

  form do |f|
    f.inputs do
      f.input :sender, collection: User.all
      f.input :receiver, collection: User.all
      f.input :content
    end
    f.actions
  end
end
