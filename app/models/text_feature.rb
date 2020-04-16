class TextFeature < PlaceableFeature
  attr_accessor :icon_id

  def build_properties
    super
    @fill = add_property(Property['Fill'], fill)

    Property.stroke_width_properties.each do |property|
      add_property(property, stroke_width(property))
    end

    Property.stroke_style_properties.each do |property|
      add_property(property, stroke_style(property))
    end

    Property.text_properties.each do |property|
      case property.name
        when 'Text'
          add_property(property, text_value)
        when 'Font Family'
          add_property(property, font_family)
        when 'Text Alignment'
          add_property(property, text_alignment_value(property))
        when 'Line Height'
          value      = line_height || property.default
          rule_value = regulated? ? [value] : []
          add_property(property, { value: value, rule: rule_value })
        else
          value      = eval("#{property.value_type}(#{self.send(property.field_name) || property.default})")
          rule_value = regulated? ? [value] : []
          add_property(property, { value: value, rule: rule_value })
      end
    end
  end

  def value
    text_value.fetch(:value, '')
  end

  def value=(value)
    @text = value
  end

  def text_value
    if text.present?
      value = text
    else
      if regulation_feature.present? && regulation_feature.text.present?
        value = regulation_feature.text
      else
        value = feature.sample_value
      end
    end

    rule_value = regulated? ? [value] : []

    {
        value: value,
        rule:  rule_value
    }
  end

  # Helper to identify a designer added feature.
  # It is set to true in Designer Added Icon Features.
  def designer_added?
    false
  end

  protected

  # There's either Colour(s), Exclusions (with or without Contrasting), Contrasting
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
      elsif contrasting.present?
        rule_colours = [default_fill_colour]
      end

      if rule_colours.present?
        designer_colours -= rule_colours
        # regulated colours are to be added onto unregulated features' designer colour palettes
        list_of_regulated_colours << rule_colours

        unless rule_colours.include? default_fill_colour
          default_fill_colour = rule_colours.first
        end
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
      default_stroke_style = fam_border_colour || stroke_colour(property.stroke_level, @fill[:value])
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

  def font_family
    designer_font_ids = font_ids
    rule_font_ids     = []
    default_font_id   = designer_font_ids.first

    # Reloading a Kit - in case ne of the More fonts was selected
    if font_id.present? && !designer_font_ids.include?(font_id)
      designer_font_ids << font_id
    end

    if regulated?
      rule_font_ids = regulation_feature.font_ids
      unless rule_font_ids.empty?
        designer_font_ids = designer_font_ids - rule_font_ids
        default_font_id   = rule_font_ids.first
      end
    end

    {
        value:    font_id || default_font_id,
        rule:     rule_font_ids,
        designer: designer_font_ids
    }
  end


  def text_alignment_value(property)
    value      = text_alignment || property.default
    rule_value = regulated? ? [value] : []

    {
        value: value,
        rule:  rule_value
    }
  end

  def line_height_value(property)
    {
        value: line_height || property.default,
        rule:  [] # TODO temporary hack, need to get proper rule values - CM
    }
  end

end
