class FontPalette < ActiveRecord::Base

  has_many :font_palette_fonts
  has_many :fonts,
           through: :font_palette_fonts

  has_many :target_kits
  has_many :manufacturers
  has_many :target_categories

  def font_ids
    font_palette_fonts.pluck(:font_id)
  end

end
