class CreateBids < ActiveRecord::Migration[7.0]
  def change
    create_table :bids do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.decimal :proposed_price, precision: 10, scale: 2
      t.text :cover_letter

      t.timestamps
    end
  end
end
