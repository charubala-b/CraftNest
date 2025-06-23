class Review < ApplicationRecord
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewee, class_name: 'User'
  belongs_to :project

  validates :ratings, presence: true, inclusion: { in: 1..5 }
  validates :review, presence: true
  validates :reviewer_id, uniqueness: { scope: :project_id, message: "has already reviewed this project." }
end
