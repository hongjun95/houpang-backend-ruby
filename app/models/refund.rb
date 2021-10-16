class Refund < ApplicationRecord
    belongs_to :order_item
    belongs_to :refundee, :foreign_key => "user_id", class_name: "User"
    enum status: { 
        Exchanged: 0,
        Refunded: 1,
    }
end
