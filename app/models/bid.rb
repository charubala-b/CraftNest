class Bid < ApplicationRecord
  include Ransackable
  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: [ false, nil ]) }
  scope :ordered_by_price_asc, -> { order(proposed_price: :asc) }


  after_update :create_contract_if_accepted

  belongs_to :project
  belongs_to :user
  belongs_to :contract, optional: true

  validates :cover_letter, presence: { message: "can't be blank" },
                           length: { minimum: 20, maximum: 100, too_short: "must be at least 20 characters", too_long: "must be at most 100 characters" }
  validates :proposed_price, presence: true, numericality: { greater_than: 0 }

  ransacker :price_above_100, type: :boolean do
    Arel.sql("CASE WHEN proposed_price > 100 THEN TRUE ELSE FALSE END")
  end

  private

  def create_contract_if_accepted
    return unless saved_change_to_accepted? && accepted?
    return if Contract.exists?(project_id: project_id, freelancer_id: user_id)

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
