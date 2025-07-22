ActiveAdmin.register User do
  permit_params :email, :name, :role, :created_at

  scope :all, default: true
  scope("Freelancer") { |users| users.where(role: "freelancer") }
  scope("Client")     { |users| users.where(role: "client") }
  scope("Created This Week") { |users| users.where("created_at >= ?", 1.week.ago) }

  filter :email
  filter :name

  filter :created_year, as: :numeric, label: "Created Year"
  filter :created_month, as: :select, label: "Created Month", collection: 1..12

  filter :created_at


  index do
    selectable_column
    id_column
    column :email
    column :name
    column :role
    column :created_at
    actions
  end


  collection_action :export_freelancers, method: :get do
    require "csv"
    freelancers = User.where(role: "freelancer")
    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "ID", "Name", "Email", "Created At" ]
      freelancers.each do |user|
        csv << [ user.id, user.name, user.email, user.created_at ]
      end
    end
    send_data csv_data, filename: "freelancers-#{Date.today}.csv"
  end

  action_item :export_csv, only: :index do
    link_to "Export Freelancers CSV", export_freelancers_admin_users_path(format: :csv)
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :role, as: :select, collection: [ "freelancer", "client", "admin" ]
    end
    f.actions
  end
end
