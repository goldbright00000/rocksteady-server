class ProductLineSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :is_regulated
end
