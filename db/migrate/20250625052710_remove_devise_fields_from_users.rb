class RemoveDeviseFieldsFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
    # Add more if needed (confirmable, lockable, etc.)
  end
end
