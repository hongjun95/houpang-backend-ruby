class RemoveColumnFormCategory < ActiveRecord::Migration[6.0]
  def change
    remove_column :categories, :body
    remove_column :categories, :position
  end
end
