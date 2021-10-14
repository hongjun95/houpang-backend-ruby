class RenameColumFromOrder < ActiveRecord::Migration[6.0]
  def change
    rename_column :orders, :deliverRequest, :deliver_request
    rename_column :orders, :orderedAt, :ordered_at
  end
end
