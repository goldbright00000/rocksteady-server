class ColourSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :display_rgb,
             :print_cmyk,
             :contrasting_ids,
             :complementary_ids,
             :group_default,
             :group

  def complementary_ids
    object.complementary_colour_ids
  end

  def contrasting_ids
    object.contrasting_colour_ids
  end

  def group
    object.colour_group.try(:display_name)
  end

  def group_default
    object.colour_group.try(:default_colour) == object
  end

end
