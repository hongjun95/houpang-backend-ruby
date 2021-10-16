class ItemSerializer < Panko::Serializer
  # include ImagableSerializer
  attributes :id, :user_id, :name, :sale_price, :description,
              :category_id, :infos, :product_images, :images

  has_one :category, serializer: CategorySerializer
  has_one :provider, serializer: UserSerializer
  has_many :images, serializer: ImageSerializer
  # has_many :orders, :foreign_key => :consumer_id
end
