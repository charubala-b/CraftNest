class User < ApplicationRecord
  include EmailDowncaseable
  include Ransackable
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :omniauthable, omniauth_providers: [ :google_oauth2 ]


  before_save :downcase_email

  enum :role, { freelancer: 0, client: 1 }

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

  has_many :skill_assignments, as: :skillable, dependent: :destroy
  has_many :skills, through: :skill_assignments

  has_many :contracts_as_freelancer, class_name: "Contract", foreign_key: "freelancer_id", dependent: :destroy



  ransacker :created_year do
    Arel.sql("EXTRACT(YEAR FROM users.created_at)::integer")
  end

  ransacker :created_month do
    Arel.sql("EXTRACT(MONTH FROM users.created_at)::integer")
  end


  def downcase_email
    self.email = email.downcase if email.present?
  end
end
