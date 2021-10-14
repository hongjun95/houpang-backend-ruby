class RefundEachSerializer < Panko::Serializer
  # include ImagableSerializer

  attributes :id, :count, :status, :refunded_at, :problem_title, :problem_description, :recall_palce, :recall_day,
             :recall_title, :recall_description, :send_place, :send_day, :order_item_id, :user_id

  has_one :order_item, serializer: OrderItemSerializer
  has_one :user, serializer: UserSerializer
end
