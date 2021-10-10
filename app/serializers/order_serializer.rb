class OrderSerializer < Panko::Serializer
  # include ImagableSerializer
  attributes :id, :total, :destination, :deliver_request,
  :ordered_at, :consumer_id

  has_many :order_items, serializer: OrderItemEachSerializer
  # has_one :consumer, serializer: ConsumerSerializer
  has_one :user, serializer: ConsumerSerializer
end
