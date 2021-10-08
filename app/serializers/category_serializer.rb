class CategorySerializer < Panko::Serializer
  attributes :id, :title, :coverImg

  delegate :image_path, to: :object
end
