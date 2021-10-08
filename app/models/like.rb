class Like < ApplicationRecord
  include ImageUrl # todo 없애야할 것
  belongs_to :user
  has_and_belongs_to_many :items
end
