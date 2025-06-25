class ChangeSkillNameToString < ActiveRecord::Migration[7.2]
  def change
  change_column :skills, :skill_name, :string
  end
end
