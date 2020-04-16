class InterviewIconRuleSet < ActiveRecord::Base
  belongs_to :interview_icon
  belongs_to :rule_set
  belongs_to :product_line
end
