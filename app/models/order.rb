class Order < ApplicationRecord
    include ImageUrl # todo 없애야할 것
    belongs_to :user
end
