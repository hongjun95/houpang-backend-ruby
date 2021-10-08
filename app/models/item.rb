class Item < ApplicationRecord
  include ImageUrl
  include Imagable
  belongs_to :user
  belongs_to :category
  has_and_belongs_to_many :likes
  paginates_per 10
  enum status: { active: 0, disabled: 1 }
end
