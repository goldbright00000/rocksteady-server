class RegulationColourPaletteColour < ActiveRecord::Base

  belongs_to :colour
  belongs_to :regulation_colour_palette

  default_scope -> { where('colour_id > ?', Colour::CONTRASTING) }
end
