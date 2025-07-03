attributes :id, :status, :created_at, :updated_at

child :project do
  attributes :id, :title, :description
end

child :freelancer do
  attributes :id, :name, :email
end

child :client do
  attributes :id, :name, :email
end
