# Colour stores colours and their related representations like rgb, cmyk etc.
class Colour < ActiveRecord::Base
  CONTRASTING = -1

  has_many :colour_palette_colours
  has_many :colour_palettes, through: :colour_palette_colours

  has_and_belongs_to_many :complementary_colours, foreign_key: 'colour_id',
    association_foreign_key:  'complementary_colour_id', join_table: 'complementary_colours', class_name: 'Colour'

  has_and_belongs_to_many :contrasting_colours,   foreign_key: 'colour_id',
    association_foreign_key:  'contrasting_colour_id', join_table: 'contrasting_colours', class_name: 'Colour'

  has_many :feature_placements
  has_many :regulation_colour_palette_colours
  has_many :regulation_colour_palettes, through: :regulation_colour_palette_colours

  belongs_to :colour_group

  default_scope { where(display_colour: true).where('colours.id > ?', CONTRASTING) }

  def name
    display_name
  end

  def self.purple
    unscoped.where(display_name: 'Purple').first!
  end

  def self.white
    unscoped.where(display_name: 'White').first!
  end

  def contrast_id
    if contrasting_colours.any?
      contrasting_colours.first.id
    else
      if display_rgb.eql?(Colour.purple.display_rgb)
        Colour.white.id
      else
        Colour.purple.id
      end
    end
  end

  # Unrestricted colour range. Used in pdf generation.
  def self.one_by_display_rgb(rgb)
    rgb = "##{rgb}" unless rgb.start_with?('#'.freeze)
    rgb.downcase!

    unscoped.where('LOWER(display_rgb) = ?', rgb).take
  end

end
