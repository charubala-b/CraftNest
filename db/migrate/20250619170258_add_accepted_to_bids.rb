class AddAcceptedToBids < ActiveRecord::Migration[7.2]
  def change
    add_column :bids, :accepted, :boolean
  end
end
