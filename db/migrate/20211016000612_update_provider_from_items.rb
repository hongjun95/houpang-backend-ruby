class UpdateProviderFromItems < ActiveRecord::Migration[6.0]
  def change
    remove_reference :items, :user
    add_reference :items, :user, null: false, foreign_key: true, on_delete: :cascade
    # remove_foreign_key :items, :users
    # add_foreign_key :items, :users, on_delete: :cascade
  end
end
