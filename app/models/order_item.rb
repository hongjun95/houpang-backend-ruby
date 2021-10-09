class OrderItem < ApplicationRecord
    include ImageUrl # todo 없애야할 것0
    belongs_to :user
    belongs_to :order
    belongs_to :item
    enum status: { 
        Checking: 0,
        Received: 1,
        Delivering: 2,
        Delivered: 3,
        Canceled: 4,
        Exchanged: 5,
        Refunded: 6,
    }
end
