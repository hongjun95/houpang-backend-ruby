class Like < ApplicationRecord
  # include ImageUrl # todo 없애야할 것
  belongs_to :created_by, :foreign_key => "user_id", class_name: "User"
  has_and_belongs_to_many :items
end
