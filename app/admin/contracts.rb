ActiveAdmin.register Contract do
  actions :index, :show
  permit_params :freelancer_id, :client_id, :project_id, :start_date, :end_date

  includes :freelancer, :client, :project

  scope :all, default: true
  scope("Active Contracts") { |contracts| contracts.where("start_date <= ? AND end_date >= ?", Time.current, Time.current) }
  scope("Completed Contracts") { |contracts| contracts.where("end_date < ?", Time.current) }

  index do
    selectable_column
    id_column
    column("Freelancer") { |c| c.freelancer.name }
    column("Client")     { |c| c.client.name }
    column("Project")    { |c| c.project.title }
    column :start_date
    column :end_date
    column :created_at
    actions
  end

  filter :freelancer, collection: -> { User.where(role: :freelancer) }
  filter :client, collection: -> { User.where(role: :client) }
  filter :project_id,
       as: :select,
       label: "Project",
       collection: -> { Project.pluck(:title, :id) }
  filter :start_date
  filter :end_date

  form do |f|
    f.inputs do
      f.input :freelancer, collection: User.where(role: :freelancer)
      f.input :client,     collection: User.where(role: :client)
      f.input :project
      f.input :start_date, as: :datepicker
      f.input :end_date,   as: :datepicker
    end
    f.actions
  end
end
