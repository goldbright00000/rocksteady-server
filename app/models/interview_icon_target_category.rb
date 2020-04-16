class InterviewIconTargetCategory < ActiveRecord::Base
  belongs_to :interview_icon
  belongs_to :target_category
  belongs_to :product_line
end
