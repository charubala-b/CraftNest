attributes :id, :cover_letter, :proposed_price, :accepted, :created_at, :updated_at

child :user do
  attributes :id, :name, :email
end

child :project do
  attributes :id, :title
end
