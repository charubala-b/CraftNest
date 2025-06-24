class Project < ApplicationRecord
  scope :active, -> { where("deadline > ?", Date.today) }
  scope :completed, -> { where("deadline <= ?", Date.today) }

  
  before_destroy :log_project_destruction
  belongs_to :client, class_name: "User"

  has_many :bids, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :project_skills, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :skills, through: :project_skills
  has_many :freelancers, -> { where(role: :freelancer) }, through: :bids, source: :user
  validates :budget, numericality: { greater_than_or_equal_to: 0, message: "must be a non-negative number" }
  validates :title, :description, :budget, :deadline, presence: true
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: "has already been taken" }
  validate :deadline_cannot_be_in_the_past
  

  private

  def deadline_cannot_be_in_the_past
    if deadline.present? && deadline <= Date.today
      errors.add(:deadline, "can't be in the past. Please select today or a future date.")
    end
  end

  def log_project_destruction
    Rails.logger.info "Project '#{title}' is being deleted."
  end
end

