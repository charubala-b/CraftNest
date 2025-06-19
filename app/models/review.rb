class Review < ApplicationRecord
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"
  belongs_to :project

  has_many :comments, as: :commentable
  validates :ratings, inclusion: { in: 1..5 }
  validates :review, presence: true
end

