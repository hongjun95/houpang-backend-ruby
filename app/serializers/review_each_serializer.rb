class ReviewEachSerializer < Panko::Serializer
  attributes :id, :user_id, :item_id, :content, :rating, :created_at

  has_one :item, serializer: ItemSerializer
  has_one :commenter, serializer: UserSerializer
  has_many :images, serializer: ImageSerializer
end
