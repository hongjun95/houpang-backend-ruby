class ItemEachSerializer < Panko::Serializer
  include ImagableSerializer

  attributes :id, :user_id, :name, :sale_price, :category_id, :infos, :product_images

  has_one :category, serializer: CategorySerializer
end
