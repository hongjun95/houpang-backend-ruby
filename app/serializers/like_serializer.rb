class LikeSerializer < Panko::Serializer
  attributes :id, :items, :created_by

  has_one :created_by, serializer: UserSerializer
  has_many :items, serializer: ItemEachSerializer
end