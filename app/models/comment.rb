class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy

  validates :body, presence: true, length: { minimum: 20 , maximum: 100}

  after_create :notify_project_owner
  before_destroy :log_deletion

  private

  def notify_project_owner
    if user.freelancer? && project.client.present?
      Rails.logger.info "Notified project owner (User ##{project.client_id}) about comment ##{id}"
    end
  end

  def log_deletion
    Rails.logger.info "Comment ##{id} is being deleted by User ##{user_id}"
  end
end
