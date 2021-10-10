class UserSerializer < Panko::Serializer
  include ImagableSerializer

  attributes :id, :email, :name, :image
end
