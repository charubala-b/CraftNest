class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.string :budget
      t.datetime :deadline
      t.references :client, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
