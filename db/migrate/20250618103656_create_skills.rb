class CreateSkills < ActiveRecord::Migration[7.0]
  def change
    create_table :skills do |t|
      t.integer :skill_name, null: false

      t.timestamps
    end
  end
end
