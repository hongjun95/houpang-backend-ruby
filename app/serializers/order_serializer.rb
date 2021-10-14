class OrderSerializer < Panko::Serializer
  # include ImagableSerializer
  attributes :id, :total, :destination, :deliver_request,
  :ordered_at, :user_id

  has_many :order_items, serializer: OrderItemEachSerializer
  has_one :consumer, serializer: ConsumerSerializer
end
