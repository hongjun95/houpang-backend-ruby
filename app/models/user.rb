class User < ApplicationRecord
  paginates_per 8
  include ImageUrl
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  has_many :items, dependent: :nullify
  # has_many :orders, dependent: :nullify
  # has_many :orders, :foreign_key => :consumer_id, :primary_key => :uid, dependent: :nullify
  has_many :orders, dependent: :nullify
  has_many :order_items, dependent: :nullify
  has_many :refunds, dependent: :destroy
  has_one :like, dependent: :destroy
  enum gender: { unknown: 0, male: 1, female: 2 }
  enum role: {
    Consumer: 0,
    Provider: 1,
    Admin: 2,
  }
end
