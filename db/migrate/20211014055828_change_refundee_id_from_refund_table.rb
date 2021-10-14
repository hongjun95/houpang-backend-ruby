class ChangeRefundeeIdFromRefundTable < ActiveRecord::Migration[6.0]
  def change
    remove_reference :refunds, :refundee
    add_reference :refunds, :user, null: false, foreign_key: true
  end
end
