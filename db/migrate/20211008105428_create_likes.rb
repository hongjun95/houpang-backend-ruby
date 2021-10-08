class CreateLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    
    create_join_table :likes, :items do |t|
      t.index :like_id
      t.index :item_id
    end
  end
end
