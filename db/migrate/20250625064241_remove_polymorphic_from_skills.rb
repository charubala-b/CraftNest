class RemovePolymorphicFromSkills < ActiveRecord::Migration[7.2]
  def change
    remove_column :skills, :skillable_type, :string
    remove_column :skills, :skillable_id, :bigint
  end
end
