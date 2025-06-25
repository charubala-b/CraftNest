class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :project

  validates :body, presence: true, length: { minimum: 20 , maximum: 100}

  after_create :notify_receiver

private

def notify_receiver
   Rails.logger.info "Notified User ##{receiver_id} about new message ##{id}"
end

end
