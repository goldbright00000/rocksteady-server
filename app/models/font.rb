# Defines each font with it's related svg data.
class Font < ActiveRecord::Base

  has_many :feature_placements, foreign_key: 'font_family_id'
  has_many :font_palette_fonts
  has_many :font_palettes, through: :font_palette_fonts

  def font_data
    data
  end

end
