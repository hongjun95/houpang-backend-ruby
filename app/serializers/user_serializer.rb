  class UserSerializer < Panko::Serializer
    include ImagableSerializer

    attributes :id, :email, :name, :image :description, :image_ids

  end
