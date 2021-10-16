class ItemEachSerializer < Panko::Serializer
  attributes :id, :user_id, :name, :sale_price, :category_id, :infos, :reviews_average

  has_one :category, serializer: CategorySerializer
  has_many :images, serializer: ImageSerializer
end
