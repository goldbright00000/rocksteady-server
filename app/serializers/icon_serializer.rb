class IconSerializer < ActiveModel::Serializer
  attributes :id,
             :graphic_url,
             :name,
             :tags,
             :design_category,
             :multicoloured

  def graphic_url
    "/data/graphics/#{object.id}.#{object.extension}"
  end

  # TODO: Determine if tags are needed here at all - if search comes to the server
  # is there much point in sending the tags to the client (6k icons and counting)
end
