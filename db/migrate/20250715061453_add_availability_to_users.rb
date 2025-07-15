class AddAvailabilityToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :available_for_work, :boolean
    add_column :users, :busy_until, :date
  end
end
