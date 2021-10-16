class Order < ApplicationRecord
    # belongs_to :user
    belongs_to :consumer, :foreign_key => "user_id", class_name: "User"
    has_many :order_items, dependent: :destroy
end
