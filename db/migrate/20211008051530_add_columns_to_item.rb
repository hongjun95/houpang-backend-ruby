# stock, images[], avgRating, infos, orderItems, reviews
class AddColumnsToItem < ActiveRecord::Migration[6.0]
  def change
    change_table :items do |t|
      t.integer :stock
      t.string 'images', array: true
      t.float :avgRating
    end
    add_index :items, :images, using: 'gin'
  end
end