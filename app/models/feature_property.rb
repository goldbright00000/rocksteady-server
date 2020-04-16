class FeatureProperty < ActiveRecord::Base
  belongs_to :feature
  belongs_to :property
end
