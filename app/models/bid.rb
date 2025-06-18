class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :proposed_price, numericality: { greater_than_or_equal_to: 0 }
  validates :cover_letter, presence: true
end
