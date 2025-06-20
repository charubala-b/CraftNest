class ChangeCommentsToUseProjectReference < ActiveRecord::Migration[7.2]
  def change
        remove_column :comments, :commentable_type, :string
        remove_column :comments, :commentable_id, :bigint
        add_reference :comments, :project, foreign_key: true
  end
end
