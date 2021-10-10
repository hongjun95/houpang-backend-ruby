class Order < ApplicationRecord
    # belongs_to :user
    belongs_to :user, :foreign_key => :consumer_id
    has_many :order_items, dependent: :destroy
end
