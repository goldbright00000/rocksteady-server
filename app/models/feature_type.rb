require_relative '../../lib/eav_fields'

class FeatureType < ActiveRecord::Base

  eav_fields

  has_many :features

end


