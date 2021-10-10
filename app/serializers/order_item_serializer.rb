  class OrderItemSerializer < Panko::Serializer
    # include ImagableSerializer
    attributes :id, :user_id, :item_id, :count, :status, :order_id
  end
