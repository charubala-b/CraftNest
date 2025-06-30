ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  scope :all, default: true
  scope("Created This Month") { |admins| admins.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }

  index do
    selectable_column
    id_column
    column :email
    column :created_at
    actions
  end

  filter :email_cont, as: :string, label: "Email Contains"
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
