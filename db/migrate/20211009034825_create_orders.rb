class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.integer :total
      t.string :destination
      t.string :deliverRequest
      t.string :orderedAt
      t.references :user, null: true, foreign_key: true
      t.timestamps
    end
  end
end
