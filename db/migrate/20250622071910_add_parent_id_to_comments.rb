class AddParentIdToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :parent_id, :integer
  end
end
