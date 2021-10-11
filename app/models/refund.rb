class Refund < ApplicationRecord
    belongs_to :order_item
    belongs_to :user, :foreign_key => :refundee_id
end
