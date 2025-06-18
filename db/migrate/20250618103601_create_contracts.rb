class CreateContracts < ActiveRecord::Migration[7.0]
  def change
    create_table :contracts do |t|
      t.references :project, null: false, foreign_key: true
      t.references :freelancer, null: false, foreign_key: { to_table: :users }
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.datetime :start_date
      t.datetime :end_date
      t.integer :status, default: 0 # enum: { draft: 0, inprogress: 1, completed: 2 }

      t.timestamps
    end
  end
end
