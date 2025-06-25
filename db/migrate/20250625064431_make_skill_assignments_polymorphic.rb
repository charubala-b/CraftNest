class MakeSkillAssignmentsPolymorphic < ActiveRecord::Migration[7.2]
  def change
    add_column :skill_assignments, :skillable_type, :string
    add_column :skill_assignments, :skillable_id, :bigint

    add_index :skill_assignments, [:skillable_type, :skillable_id]
  end
end
