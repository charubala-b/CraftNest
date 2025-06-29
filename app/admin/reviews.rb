ActiveAdmin.register Review do
  permit_params :reviewer_id, :reviewee_id, :project_id, :ratings, :review


  scope :all, default: true
  scope("5-Star Reviews")        { |reviews| reviews.where(ratings: 5) }
  scope("Low Ratings (1–2 Stars)") { |reviews| reviews.where(ratings: 1..2) }
  scope("Recent Reviews")        { |reviews| reviews.where("created_at >= ?", 7.days.ago) }
  scope("Old Reviews")           { |reviews| reviews.where("created_at < ?", 30.days.ago) }

  index do
    selectable_column
    id_column
    column :reviewer
    column :reviewee
    column :project
    column :ratings
    column :review
    column :created_at
    actions
  end

  filter :reviewer, collection: -> { User.all }
  filter :reviewee, collection: -> { User.all }
  filter :project
  filter :ratings
  filter :created_at

  form do |f|
    f.inputs do
      f.input :reviewer, collection: User.all
      f.input :reviewee, collection: User.all
      f.input :project
      f.input :ratings, as: :select, collection: 1..5
      f.input :review
    end
    f.actions
  end
end
