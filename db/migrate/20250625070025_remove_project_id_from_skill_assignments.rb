class RemoveProjectIdFromSkillAssignments < ActiveRecord::Migration[7.2]
  def change
    remove_column :skill_assignments, :project_id, :bigint
  end
end
