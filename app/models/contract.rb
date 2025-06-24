class Contract < ApplicationRecord
  belongs_to :project
  belongs_to :freelancer, class_name: 'User'
  belongs_to :client, class_name: 'User'

  enum status: { active: 1, completed: 2 }

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= :active
  end
end
