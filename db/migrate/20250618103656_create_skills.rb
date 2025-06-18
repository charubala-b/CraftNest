class CreateSkills < ActiveRecord::Migration[7.0]
  def change
    create_table :skills do |t|
      t.integer :skill_name, null: false # enum: { AI: 0, ML: 1, DS: 2, React: 3 }

      t.timestamps
    end
  end
end
