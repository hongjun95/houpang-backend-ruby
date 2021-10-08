class RenameTitleFromCategory < ActiveRecord::Migration[6.0]
  def change
    change_column :categories, :title, :string, unique: true
  end
end
