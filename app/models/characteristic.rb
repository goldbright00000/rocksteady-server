# A Characteristic is a distinguishing attribute of a Target that may be used to
# determine the Uses available for the Target based on the Constraints specified
# in the associated RegulationConstraints
#
# TargetCharacteristics ALWAYS contain an exact value
# Constraints may specify a range or an exact value
#
# Examples
#
# The Target Honda CRF 250R has the following TargetCharacteristics
# Stroke: 4
# Capacity: 250
#
# The Regulation ACU Motorcross MX2 has the following RegulationConstraints
# Stroke: 4
# Capacity: 176 - 250
#
class Characteristic < ActiveRecord::Base

  has_many :constraints
  has_many :target_characteristics
  has_many :targets, through: :target_characteristics
  has_many :user_characteristics
  has_many :users, through: :user_characteristics

  def self.regulation_region
    where(name: 'Regulation Region').take!
  end

end
