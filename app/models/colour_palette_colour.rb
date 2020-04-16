# Links Colours to ColourPalettes
class ColourPaletteColour < ActiveRecord::Base

  belongs_to :colour_palette
  belongs_to :colour

  default_scope { joins(:colour).order('colour_palette_colours.priority DESC, colours.display_name ASC') }

end
