class UserSerializer < Panko::Serializer
  include ImagableSerializer

  attributes :id, :email, :name, :image, :phone, :address1, :role, :user_img
end
