class ThemeTag < ActiveRecord::Base
  belongs_to :theme
  belongs_to :category, class_name: 'ThemeTagCategory'
end
