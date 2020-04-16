class FeatureTypeProperty < ActiveRecord::Base

  belongs_to :feature_type
  belongs_to :property

end
