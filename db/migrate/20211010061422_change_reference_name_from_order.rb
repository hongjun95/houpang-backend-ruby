class ChangeReferenceNameFromOrder < ActiveRecord::Migration[6.0]
  def change
    remove_reference :orders, :user, null: true, foreign_key: true
    add_reference :orders, :consumer, null: false, foreign_key: { to_table: :users }
    # add_foreign_key :orders, :users, column: :consumer_id
    
    # add_column :people, :foo_bar_store_id, :integer, index: true
    # add_foreign_key :people, :stores, column: :foo_bar_store_id
  end
end
