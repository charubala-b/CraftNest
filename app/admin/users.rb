ActiveAdmin.register User do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :email, :role, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :email, :role, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  # actions :all
  permit_params :email, :name, :role, :created_at

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :role
    column :created_at
    actions
  end
  scope :all, default:true
  scope("freelancer") do |users|
    users.where(role: 'freelancer')
  end

  scope("client") do |users|
    users.where(role: 'client')
  end

  filter :email
  filter :name

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :role
      f.input :email
    end
    f.actions
  end
  
end
