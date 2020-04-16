class RegulationFeatureProperty < ActiveRecord::Base

  belongs_to :property
  belongs_to :regulation_colour_palette
  belongs_to :regulation_feature

end
