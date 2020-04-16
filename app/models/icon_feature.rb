class IconFeature < PlaceableFeature
  belongs_to :icon

  def build_properties
    super

    icon_hash = get_icon_hash
    if icon_hash.present?
      add_property Property['Icon'], icon_hash

      @fill = add_property Property['Fill'], fill

      Property.stroke_width_properties.each do |property|
        add_property property, stroke_width(property)
      end

      Property.stroke_style_properties.each do |property|
        add_property property, stroke_style(property)
      end

      add_property Property['Flip X'], get_flip_x_hash
      add_property Property['Flip Y'], get_flip_y_hash
    else
      @empty_feature = true
    end
  end

  def designer_icon_ids
    raise NotImplementedError.new
  end

  # TODO: BM: MOT-2223 | It's just a temporary fix as we're not sure of what value to put here
  def value
    designer_icon_ids.first || Icon.default
  end

  # Helper to identify a designer added feature.
  # It is set to true in Designer Added Icon Features.
  def designer_added?
    false
  end

  protected

  def get_flip_x_hash
    value      = flip_x || Property['Flip X'].default
    value      = value == 1
    rule_value = regulated? ? [value] : []

    {
        value: value,
        rule:  rule_value
    }
  end

  def get_flip_y_hash
    value      = flip_y || Property['Flip X'].default
    value      = value == 1
    rule_value = regulated? ? [value] : []

    {
        value: value,
        rule:  rule_value
    }
  end

  # @return [Hash|nil]
  def get_icon_hash
    designer_icons = designer_icon_ids

    return nil if designer_icons.blank?

    if regulation_feature && regulation_feature.icon_id.present?
      designer_icons.unshift(regulation_feature.icon_id)
    end

    if icon_id.present?
      designer_icons.unshift(icon_id)
    end

    {
        value:    designer_icons.first,
        designer: designer_icons.uniq,
        rule:     regulated? ? [designer_icons.first] : []
    }
  end

  def fill
    default_fill_colour = fill_colour_id.present? ? fill_colour_id : contrasting_colour_id(background_fill[:value])
    rule_colours        = []
    designer_colours    = designer_colour_ids
    exclusions          = []
    contrasting         = false

    if regulated?
      contrasting, inclusions, exclusions = regulation_feature.fills
      if inclusions.present?
        rule_colours = inclusions
        rule_colours.insert(0, fill_colour_id) if fill_colour_id_fam_regulated?
        default_fill_colour = rule_colours.first
        if default_fill_colour.eql?(background_fill[:value]) && background_fill[:rule].empty?
          # The regulated text colour is the same as the unregulated background so we change the background
          order_kit_position.change_background_colour(contrasting_colour_id(default_fill_colour))
        end
      elsif exclusions.present?
        # We may have to remove some entries from the Designer Colours
        rule_colours = designer_colour_ids.reject { |designer_colour_id|
          exclusions.include?(designer_colour_id)
        }
        unless rule_colours.include?(default_fill_colour)
          if rule_colours.first.eql?(background_fill[:value])
            default_fill_colour = rule_colours.second
          else
            default_fill_colour = rule_colours.first
          end
        end
      elsif contrasting
        rule_colours = [default_fill_colour]
      end

      if rule_colours.present?
        designer_colours -= rule_colours
        # regulated colours are to be added onto unregulated features' designer colour palettes
        list_of_regulated_colours << rule_colours
      end
    else
      # flip the colour if it's matching the background's colour
      # so it will be visible in cases where the background is regulated
      # and from now on that is the new colour value to work on
      #
      # designer added features are now an exception here
      if !designer_added? && default_fill_colour.eql?(background_fill[:value])
        default_fill_colour = contrasting_colour_id(background_fill[:value])
      end

      # Add the background's contrast to the Palette when it's not there
      unless designer_colour_ids.include?(default_fill_colour)
        designer_colour_ids << default_fill_colour

        # When an icon is added to a position at least the contrasting colour of the background should be added to the colour palette
        # TODO VV: refactor this well hidden multi node delegated property to a more controllable, visible place
        background_fill[:designer] << default_fill_colour
      end
    end

    # this is an unregulated feature on a regulated kit
    if regulation.present? && rule_colours.blank?
      list_of_unregulated_features << "#{position_id}-#{feature_id}-#{Property['Fill'].id}"

      # no regulation sets it's default colour, let's check if we still need to change it to other then the background's colour
      #
      # designer added features are now an exception here
      if !designer_added? && default_fill_colour.eql?(background_fill[:value])
        default_fill_colour = contrasting_colour_id(background_fill[:value])
      end
    end

    {
        value:    default_fill_colour,
        rule:     rule_colours,
        designer: designer_colours,
        exclude:  exclusions,
        contrast: contrasting
    }
  end

  # Default them all to the same colour as the item they appear on
  def stroke_style(property)
    # need to send the fieldname to self to get saved value
    default_stroke_style = nil
    stroke_style_rule    = []

    # regulations apply?
    if regulated?
      default_stroke_style = regulation_feature.stroke_style(property.id)
      stroke_style_rule    = default_stroke_style
    end

    # no regulation applied
    if default_stroke_style.blank?
      fam_border_colour    = send(property.field_name)
      default_stroke_style = fam_border_colour.present? ? fam_border_colour : stroke_colour(property.stroke_level, @fill[:value])
    end

    {
        value: default_stroke_style,
        rule:  stroke_style_rule
    }
  end

  def stroke_colour(level, feature_colour)
    if level.odd?
      base_colours = [feature_colour, background_fill[:value]]
      stroke_style = contrasting_colour_id(feature_colour)
      if base_colours.include? stroke_style
        (designer_colour_ids - base_colours).first
      else
        stroke_style
      end
    else
      feature_colour
    end
  end

end
