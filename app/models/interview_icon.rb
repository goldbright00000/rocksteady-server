class InterviewIcon < ActiveRecord::Base
  belongs_to :product_line
  belongs_to :country
  has_many :manufacturers, :through => :interview_icon_manufacturers
  has_many :target_categories, :through => :interview_icon_target_categories
  has_many :rule_sets, :through => :interview_icon_rule_sets
  has_many :use_categories, :through => :interview_icon_use_categories
end
