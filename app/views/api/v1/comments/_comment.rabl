object @comment

attributes :id, :body, :created_at

child :user do
  attributes :id, :name, :email
end

child :replies do
  extends "api/v1/comments/_comment"
end
