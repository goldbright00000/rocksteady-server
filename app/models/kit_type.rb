class KitType < ActiveRecord::Base
  has_many :display_map_templates
  has_many :product_lines
  has_many :kits
end
