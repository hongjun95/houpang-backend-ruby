class ItemEachSerializer < Panko::Serializer
  include ImagableSerializer

  attributes :id, :user_id, :name, :sale_price, :category_id, :infos, :productImages

  has_one :category, serializer: CategorySerializer
end
