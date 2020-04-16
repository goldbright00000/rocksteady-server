class FontPaletteFont < ActiveRecord::Base

  belongs_to :font_palette
  validates :font_palette_id,
            presence: true

  belongs_to :font
  validates :font_id,
            presence: true,
            uniqueness: { scope: :font_palette_id }

end
