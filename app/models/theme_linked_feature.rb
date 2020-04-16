class ThemeLinkedFeature < ActiveRecord::Base
  belongs_to :theme
  belongs_to :feature
  belongs_to :target_category_position
end
