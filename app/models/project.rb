class Project < ApplicationRecord
  belongs_to :client, class_name: "User"

  has_many :bids, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :project_skills, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :skills, through: :project_skills
  validates :title, :description, :budget, :deadline, presence: true
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: "has already been taken" }

end
