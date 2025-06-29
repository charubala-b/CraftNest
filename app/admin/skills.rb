ActiveAdmin.register Skill do
  permit_params :name


  scope :all, default: true
  scope("Recently Added") { |skills| skills.where("created_at >= ?", 7.days.ago) }
  scope("Alphabetical Order") { |skills| skills.order(:name) }
  scope("Unused Skills") do |skills|
    skills.left_joins(:skill_assignments).where(skill_assignments: { id: nil })
  end

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end
end
