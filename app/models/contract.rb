class Contract < ApplicationRecord
  include Ransackable

  before_validation :set_default_status, on: :create

  belongs_to :project
  belongs_to :freelancer, class_name: "User"
  belongs_to :client, class_name: "User"
  belongs_to :bid, optional: true

  enum :status, { active: 1, completed: 2 }
  validates :status, inclusion: { in: statuses.keys }

  private

  def set_default_status
    self.status ||= :active
  end
end
