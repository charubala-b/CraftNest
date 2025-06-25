class AddSkillableToSkills < ActiveRecord::Migration[7.2]
  def change
    add_reference :skills, :skillable, polymorphic: true, null: true
  end
end

