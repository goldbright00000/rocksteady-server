# Defines the Characteristic values for a given Target.
class TargetCharacteristic < ActiveRecord::Base

  belongs_to :characteristic
  belongs_to :target
  has_many :constraints, through: :characteristic

end
