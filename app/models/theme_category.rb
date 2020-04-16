class ThemeCategory < ActiveRecord::Base
  has_many :themes
  belongs_to :product_line
end
