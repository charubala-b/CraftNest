class RenameProjectSkillsToSkillAssignments < ActiveRecord::Migration[7.2]
  def change
    rename_table :project_skills, :skill_assignments
  end
end
