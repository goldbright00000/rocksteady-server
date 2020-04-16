# Relates constraints to regulations
class RegulationConstraint < ActiveRecord::Base
  belongs_to :constraint
  belongs_to :regulation
end
