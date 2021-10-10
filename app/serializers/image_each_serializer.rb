class ImageEachSerializer < Panko::Serializer
  attributes :id, :image_path

  delegate :image_path, to: :object
end
