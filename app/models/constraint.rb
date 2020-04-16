# Constraints specify a characteristic and an applicable value or range of values.
# They are used by regulations to determine their applicability to a Target
# based on the TargetCharacteristics.
# They are also used to determine the applicability of a Regulation to a
# Customer based on where they are going to be competing, their age and their
# sex.
class Constraint < ActiveRecord::Base
  GLOBAL = 1

  belongs_to :characteristic
  has_many :regulation_constraints
  has_many :regulations, through: :regulation_constraints

end
