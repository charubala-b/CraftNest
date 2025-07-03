object @project

attributes :id, :title, :description, :budget, :deadline, :created_at

child :skills do
  attributes :id, :skill_name
end

