# Connects Icons to Rule_sets
class RuleSetIcon< ActiveRecord::Base

  belongs_to :icon
  belongs_to :rule_set
end
