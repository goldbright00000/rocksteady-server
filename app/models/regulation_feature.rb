require_relative '../../lib/eav_fields'

# RegulationFeature defines which Features are required per Position for a Regulation
class RegulationFeature < ActiveRecord::Base

  belongs_to :regulation
  belongs_to :position
  belongs_to :feature
  belongs_to :regulation_placement, foreign_key: 'placement_id'

  # Temporary until feature_placements populated properly
  belongs_to :placement, class_name: 'RegulationPlacement'

  has_many :regulation_colour_palettes, through: :regulation_feature_properties

  eav_fields

  scope :prohibited, -> { where(requirement: -1) }
  scope :choice, -> { where(requirement: 0) }
  scope :required, -> { where(requirement: 1) } # needed

  def prohibited?
    requirement == -1
  end

  # @raise Exception
  # @return [Array]
  def fills
    regulation_palette =
        regulation_feature_properties
            .where(property_id: Property['Fill'].id)
            .first
            .try(:regulation_colour_palette)

    if regulation_palette
      palette_colours = regulation_palette.regulation_colour_palette_colours
      contrasting     = palette_colours.unscoped.where(colour_id: Colour::CONTRASTING).exists?
      inclusions      = palette_colours.where(exclude: false).pluck(:colour_id)
      exclusions      = palette_colours.where(exclude: true).pluck(:colour_id)

      # One of the three has to be true or we're in deep do do
      raise Exception unless contrasting || inclusions.present? || exclusions.present?

      return contrasting, inclusions, exclusions
    else
      return nil, nil, nil
    end
  end

  def font_ids
    font_palette_id = regulation_feature_properties
                          .where(property_id: Property['Font Family'].id)
                          .first
                          .try(:value)
    if font_palette_id.present?
      FontPalette.where(id: font_palette_id).first.try(:font_ids)
    else
      []
    end
  end

  def icon_id
    icon_id = regulation_feature_properties
                  .where(property_id: Property['Icon'].id)
                  .first
                  .try(:value)
    icon_id.nil? ? nil : icon_id.to_i
  end

  def border_stroke(property_id)
    regulation_feature_properties
        .where(property_id: property_id)
        .first
        .try(:value)
  end


  def stroke_style(property_id)
    colour_palette_id = regulation_feature_properties
                            .where(property_id: property_id)
                            .first
                            .try(:value)
    if colour_palette_id
      palette = RegulationColourPalette.where(id: colour_palette_id).first
      if palette
        palette.regulation_colour_palette_colours.first.try(:colour_id)
      end
    end
  end

  def stroke_width(property_id)
    stroke_width = regulation_feature_properties
                       .where(property_id: property_id)
                       .first
                       .try(:value)
    stroke_width.nil? ? nil : stroke_width.to_i
  end
end
