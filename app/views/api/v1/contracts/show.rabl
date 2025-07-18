object @contract

attributes :id, :status, :created_at, :updated_at

child(@contract.project => :project) do
  attributes :id, :title, :description
end

child(@contract.freelancer => :freelancer) do
  attributes :id, :name, :email
end

child(@contract.client => :client) do
  attributes :id, :name, :email
end
