# Each TargetType has a predetermined list of Positions available.
# TargetTypePosition defines the collection of Positions available for any
# TargetType
class TargetTypePosition < ActiveRecord::Base

  belongs_to :position
  belongs_to :target_type
end
