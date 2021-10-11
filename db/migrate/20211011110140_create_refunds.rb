class CreateRefunds < ActiveRecord::Migration[6.0]
  def change
    create_table :refunds do |t|
      t.integer :count
      t.integer :status, default: 0
      t.string :refunded_at
      t.string :problem_title
      t.string :problem_description
      t.string :recall_place
      t.datetime :recall_day
      t.string :recall_title
      t.string :recall_description, null: true
      t.string :send_place, null: true
      t.datetime :send_day, null: true
      t.integer :refund_pay, null:true
      t.references :order_item, null: false, foreign_key: true
      t.references :refundee, null: false, foreign_key: { to_table: :users} # refundee
      
      t.timestamps
    end
  end
end
