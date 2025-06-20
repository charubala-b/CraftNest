class Comment < ApplicationRecord
  belongs_to :user  # the commenter
  belongs_to :project

  validates :body, presence: true
end
