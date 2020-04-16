class ThemeTagCategory < ActiveRecord::Base
  belongs_to :product_line
  has_many   :theme_tags, inverse_of: :category
end
