class Message < ApplicationRecord
  include Ransackable

  after_create :notify_receiver

  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :project

  validates :body, presence: true, length: { minimum: 2 , maximum: 100}

private

def notify_receiver
   Rails.logger.info "Notified User ##{receiver_id} about new message ##{id}"
end

end
