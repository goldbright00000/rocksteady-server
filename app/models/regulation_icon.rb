# Relates Icons to Regulations
class RegulationIcon < ActiveRecord::Base

  belongs_to :icon
  belongs_to :regulation

end
