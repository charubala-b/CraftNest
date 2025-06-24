class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_one :client, through: :project

  validates :proposed_price, numericality: { greater_than_or_equal_to: 0 , message: "price must be greater than 0 "}
  validates :cover_letter, presence: true

  after_update :notify_freelancer_if_accepted

  private

  def notify_freelancer_if_accepted
    if saved_change_to_accepted? && accepted
      Rails.logger.info "✅ Bid ##{id} by #{user.name} has been accepted for project '#{project.title}'."
    end
  end
end
