class FeaturePlacementRemoval < ActiveRecord::Base

  validates :product_line_id, presence: true
  validates :feature_id, presence: true

end
