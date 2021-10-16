class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :content, default: ''
      t.integer :rating, default: 0
      
      t.timestamps
    end
  end
end
