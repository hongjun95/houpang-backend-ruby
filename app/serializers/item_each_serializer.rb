class ItemEachSerializer < Panko::Serializer
  include ImagableSerializer

  attributes :id, :user_id, :name, :sale_price, :category_id, :infos, :product_images, :images

  has_one :category, serializer: CategorySerializer
  has_many :images, serializer: ImageSerializer
end
