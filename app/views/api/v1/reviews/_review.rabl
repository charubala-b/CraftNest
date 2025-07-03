object @review

attributes :id, :ratings, :review, :project_id, :reviewer_id, :reviewee_id, :created_at

child :reviewer do
  attributes :id, :name, :email
end

child :reviewee do
  attributes :id, :name, :email
end

child :project do
  attributes :id, :title, :description
end
