ActiveAdmin.register Message do
  actions :index, :show, :destroy
  permit_params :sender_id, :receiver_id, :content

  includes :sender, :receiver

  scope :all, default: true
  scope("Sent Today") { |messages| messages.where(created_at: Time.zone.today.all_day) }
  scope("Last 7 Days") { |messages| messages.where("created_at >= ?", 7.days.ago) }

  index do
    selectable_column
    id_column
    column("Sender") { |m| m.sender.email }
    column("Receiver") { |m| m.receiver.email }
    column :body
    column :created_at
    actions
  end

filter :sender_id,
       as: :select,
       label: "Sender",
       collection: -> { User.joins(:sent_messages).distinct.pluck(:name, :id) }

filter :receiver_id,
       as: :select,
       label: "Receiver",
       collection: -> { User.joins(:received_messages).distinct.pluck(:name, :id) }
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
