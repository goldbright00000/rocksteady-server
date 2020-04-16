class BackgroundFeature < PlaceableFeature
  belongs_to :icon

  def build_properties
    super
    @fill = add_property(Property['Fill'], fill)

    Property.background_properties.each do |property|
      case property.name
        when 'Stroke Internal 1', 'Stroke Front 1'
          add_property( property, background_border_stroke(property))
      end
    end


    Property.stroke_width_properties.each do |property|
      add_property(property, stroke_width(property))
    end

    Property.stroke_style_properties.each do |property|
      add_property(property, stroke_style(property))
    end
  end

  protected

  def background_border_stroke(property)
    instance_attribute = property.name.downcase.gsub(' ', '_').to_sym
    value = self.send(instance_attribute) || property.default

    value = regulation_feature.border_stroke(property.id) if regulated? && regulation_feature.border_stroke(property.id)

    { value: value.to_i }
  end

  def fill
    default_fill_colour = fill_colour_id.blank? ? default_background_colour_id : fill_colour_id
    rule_colours        = []
    designer_colours    = designer_colour_ids
    exclusions          = []
    contrasting         = false

    if regulated?
      contrasting, inclusions, exclusions = regulation_feature.fills

      if inclusions.present?
        # Rule Prescribes Colours
        rule_colours = inclusions
        rule_colours.insert(0, fill_colour_id) if fill_colour_id_fam_regulated?
        default_fill_colour = rule_colours.first
      elsif exclusions.present?
        # Rule Proscribes Colours
        rule_colours = designer_colour_ids.reject { |designer_colour_id|
          exclusions.include?(designer_colour_id)
        }
        if exclusions.include?(default_fill_colour)
          default_fill_colour = fill_colour_id.present? ? fill_colour_id : rule_colours.first
        end
      elsif contrasting.present?
        rule_colours = designer_colours
      end

      if rule_colours.present?
        designer_colours -= rule_colours
        # regulated colours are to be added onto unregulated features' designer colour palettes
        list_of_regulated_colours << rule_colours

        unless rule_colours.include? default_fill_colour
          default_fill_colour = rule_colours.first
        end
      end
    end

     # this is an unregulated feature on a regulated kit
    if regulation.present? && rule_colours.blank?
      list_of_unregulated_features << "#{position_id}-#{feature_id}-#{Property['Fill'].id}"
    end

    {
        value:    default_fill_colour,
        rule:     rule_colours,
        designer: designer_colours,
        exclude:  exclusions,
        contrast: contrasting
    }
  end

  # Default to the contrasting colour of the fill or the fill itself based on level
  def stroke_style(property)
    stroke_style      = nil
    stroke_style_rule = []

    if regulated?
      stroke_style      = regulation_feature.stroke_style(property.id)
      stroke_style_rule = stroke_style
    end

    if stroke_style.blank?
      fam_border_colour = send(property.field_name)

      if fam_border_colour.present?
        stroke_style = fam_border_colour
      else
        if property.stroke_level.odd?
          stroke_style = contrasting_colour_id(@fill[:value])
        else
          stroke_style = @fill[:value]
        end
      end
    end

    {
        value: stroke_style,
        rule:  stroke_style_rule
    }
  end
end
