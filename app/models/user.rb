class User < ApplicationRecord
  # Uncomment when using Devise
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable

  before_save :downcase_email

  enum role: { freelancer: 0, client: 1 }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false, message: "is already registered" }

  has_many :projects, foreign_key: :client_id, inverse_of: :client, dependent: :destroy

  has_many :bids, dependent: :destroy
  has_many :bid_projects, through: :bids, source: :project

  has_many :contracts_as_freelancer, class_name: "Contract", foreign_key: :freelancer_id, dependent: :destroy
  has_many :contracts_as_client,     class_name: "Contract", foreign_key: :client_id,     dependent: :destroy

  has_many :sent_messages,     class_name: "Message", foreign_key: :sender_id,   dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :receiver_id, dependent: :destroy

  has_many :reviews_written,  class_name: "Review", foreign_key: :reviewer_id, dependent: :destroy
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id, dependent: :destroy

  has_many :comments, dependent: :destroy

  # Skills (polymorphic)
  has_many :skill_assignments, as: :skillable, dependent: :destroy
  has_many :skills, through: :skill_assignments

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
