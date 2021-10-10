class OrderItemEachSerializer < Panko::Serializer
  # include ImagableSerializer

  attributes :id, :user_id, :item_id, :count, :status

  has_one :item, serializer: ItemSerializer
  has_one :user, serializer: UserSerializer
end
