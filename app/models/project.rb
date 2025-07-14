class Project < ApplicationRecord
  include Ransackable
  scope :active, -> { where('deadline >= ?', Time.zone.today) }
scope :completed, -> { where('deadline < ?', Time.zone.today) }

  scope :ordered_by_deadline, -> { order(deadline: :asc) }

  before_destroy :log_project_destruction

  belongs_to :client, class_name: "User", inverse_of: :projects

  has_many :bids, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :skill_assignments, as: :skillable, dependent: :destroy
  has_many :skills, through: :skill_assignments
  has_many :freelancers, -> { where(role: :freelancer) }, through: :bids, source: :user

  validates :title, presence: true,
                    uniqueness: { case_sensitive: false, message: "has already been taken" },
                    length: { minimum: 20, maximum: 100 }

  validates :description, :budget, :deadline, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0, message: "must be a non-negative number" }
  validate :deadline_cannot_be_in_the_past

  private

  def deadline_cannot_be_in_the_past
    if deadline.present? && deadline < Time.zone.today
      errors.add(:deadline, "can't be in the past.")
    end
  end

  def log_project_destruction
    Rails.logger.info "Project '#{title}' is being deleted."
  end
end
