# A TargetType is the type of the Target - e.g. Motorbike, Motorcar etc
class TargetType < ActiveRecord::Base

  has_many :product_lines
  has_many :target_categories
  has_many :targets
  has_many :target_type_decals
  has_many :target_type_positions

end
