class AddProductImagesToItem < ActiveRecord::Migration[6.0]
  def change
    change_table :items do |t|
      t.string 'productImages', array: true
    end
    add_index :items, :productImages, using: 'gin'
  end
end
