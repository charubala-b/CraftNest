class Project < ApplicationRecord
  belongs_to :client, class_name: "User"

  has_many :bids, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :project_skills, dependent: :destroy
  has_many :skills, through: :project_skills
  has_many :reviews, dependent: :destroy
  validates :title, :description, :budget, :deadline, presence: true
end
