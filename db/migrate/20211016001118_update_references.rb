class UpdateReferences < ActiveRecord::Migration[6.0]
  def change
    remove_reference :order_items, :item
    add_reference :order_items, :item, null: false, foreign_key: true, on_delete: :cascade

    remove_reference :items, :category
    add_reference :items, :category, null: false, foreign_key: true, on_delete: :cascade

    remove_reference :order_items, :item
    add_reference :order_items, :item, null: false, foreign_key: true, on_delete: :cascade
  end
end
