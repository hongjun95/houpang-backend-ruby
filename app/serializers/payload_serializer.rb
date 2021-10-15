class PayloadSerializer < Panko::Serializer
  include ImagableSerializer
  attributes :id, :email, :name, :phone, :address1, :role, :user_img
end
