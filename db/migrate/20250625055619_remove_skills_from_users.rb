class RemoveSkillsFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :skills, :string
  end
end
