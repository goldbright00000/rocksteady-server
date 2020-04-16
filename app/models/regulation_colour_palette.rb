class RegulationColourPalette < ActiveRecord::Base

  belongs_to :regulation_feature_property
  has_many :regulation_colour_palette_colours
end
