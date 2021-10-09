class Order < ApplicationRecord
    include ImageUrl # todo 없애야할 것0
    belongs_to :user
    has_many :order_items, dependent: :destroy
end
