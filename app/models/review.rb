class Review < ApplicationRecord
    validates :rating, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
    belongs_to :commenter, :foreign_key => "user_id", class_name: "User"
end
