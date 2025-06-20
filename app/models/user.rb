class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false, message: "is already registered" }

  enum role: { freelancer: 0, client: 1 }
  enum skills: { ai: 0, ml: 1, ds: 2, react: 3 }, _prefix: true

  has_many :projects, foreign_key: :client_id, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :contracts_as_freelancer, class_name: "Contract", foreign_key: :freelancer_id, dependent: :destroy
  has_many :contracts_as_client, class_name: "Contract", foreign_key: :client_id, dependent: :destroy
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :receiver_id, dependent: :destroy
  has_many :reviews_written, class_name: "Review", foreign_key: :reviewer_id, dependent: :destroy
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :client_contracts, class_name: 'Contract', foreign_key: 'client_id'

  has_many :freelancer_contracts, class_name: 'Contract', foreign_key: 'freelancer_id'
end
