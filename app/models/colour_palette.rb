# Defines a colour palette
class ColourPalette < ActiveRecord::Base

  has_many :colour_palette_colours
  has_many :colours, through: :colour_palette_colours
  has_many :target_kits

  default_scope {
    includes(:colour_palette_colours)
  }

  def colour_ids
    if @colour_ids.blank?
      @colour_ids = colour_palette_colours.map { |c| c.colour_id }
    end

    @colour_ids.dup
  end

  def self.none
    ColourPalette.new do |cp|
      cp.colour_palette_colours.build(colour_id: Colour.purple.id)
    end
  end

end
