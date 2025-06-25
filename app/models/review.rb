class Review < ApplicationRecord
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewee, class_name: 'User'
  belongs_to :project

  validates :ratings, presence: true, inclusion: { in: 1..5 }
  validates :review, presence: true, length: { minimum: 20 , maximum: 100}
  validates :reviewer_id, uniqueness: { scope: :project_id, message: "has already reviewed this project." }

  after_create :notify_reviewee

private

def notify_reviewee
  Rails.logger.info "Notified reviewee (User ##{reviewee_id}) about review ##{id}"
end

end
