class InterviewIconManufacturer < ActiveRecord::Base
  belongs_to :interview_icon
  belongs_to :manufacturer
  belongs_to :product_line
end
