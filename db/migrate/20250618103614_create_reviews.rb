class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, null: false, foreign_key: { to_table: :users }
      t.references :project, null: false, foreign_key: true
      t.integer :ratings
      t.text :review

      t.timestamps
    end
  end
end
