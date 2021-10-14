class Item < ApplicationRecord
  include ImageUrl
  include Imagable
  # belongs_to :provider
  belongs_to :provider, :foreign_key => "user_id", class_name: "User"
  belongs_to :category
  has_and_belongs_to_many :likes
  has_many :order_items, dependent: :destroy
  paginates_per 10
  enum status: { active: 0, disabled: 1 }
end
