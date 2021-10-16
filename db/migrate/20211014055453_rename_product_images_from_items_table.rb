class RenameProductImagesFromItemsTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :items, :productImages, :product_images
  end
end
