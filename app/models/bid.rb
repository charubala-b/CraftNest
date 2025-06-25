class Bid < ApplicationRecord
  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }

  scope :ordered_by_price_desc, -> { order(proposed_price: :desc) }

  belongs_to :project
  belongs_to :user

  has_one :contract, dependent: :destroy

  validates :cover_letter, presence: { message: "can't be blank" },
                         length: { minimum: 20, maximum: 100, too_short: "must be at least 20 characters", too_long: "must be at most 100 characters" }
  validates :proposed_price, presence: true, numericality: { greater_than: 0 }

  after_update :create_contract_if_accepted

  private

  def create_contract_if_accepted
    return unless saved_change_to_accepted? && accepted?

    Contract.create!(
      project: project,
      client: project.client,
      freelancer: user,
      status: :active,
      start_date: Time.current,
      end_date: project.deadline
    )
  end
end
