class AddColumnsToItem2 < ActiveRecord::Migration[6.0]
  def change
    change_table :items do |t|
      t.json 'infos', array: true
    end
  end
end
