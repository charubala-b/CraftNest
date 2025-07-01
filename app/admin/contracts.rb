ActiveAdmin.register Contract do
  actions :index, :show
  permit_params :freelancer_id, :client_id, :project_id, :start_date, :end_date, :status

  includes :freelancer, :client, :project

  scope :all, default: true
  scope("Active Contracts") { |contracts| contracts.where("status = ?", 1) }
  scope("Completed Contracts") { |contracts| contracts.where("status = ?", 2) }

  index do
    selectable_column
    id_column
    column("Freelancer") { |c| c.freelancer.name }
    column("Client")     { |c| c.client.name }
    column("Project")    { |c| c.project.title }
    column :start_date
    column :end_date
    column :created_at
    column :status
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


  member_action :download_pdf, method: :get do
    pdf = Prawn::Document.new
    pdf.text "Contract ##{resource.id}", size: 24, style: :bold
    pdf.move_down 20
    pdf.text "Freelancer: #{resource.freelancer.name}"
    pdf.text "Client: #{resource.client.name}"
    pdf.text "Project: #{resource.project.title}"
    pdf.text "Start Date: #{resource.start_date}"
    pdf.text "End Date: #{resource.end_date}"
    pdf.text "Status: #{resource.status}"
    pdf.text "Created At: #{resource.created_at}"

    send_data pdf.render,
              filename: "contract_#{resource.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  #
  # ✅ Button for Download
  #
  action_item :download_pdf, only: :show do
    link_to "Download as PDF", download_pdf_admin_contract_path(resource)
  end
end
