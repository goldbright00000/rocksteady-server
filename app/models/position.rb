# A Position occurs on a Target, at which there is a Component on which we can
# place a Shape (Decal).
class Position < ActiveRecord::Base

  has_many :display_map_positions
  has_many :display_maps, through: :display_map_positions
  has_many :kit_components
  has_many :order_kit_positions
  has_many :regulation_features
  has_many :target_categories, through: :target_category_positions
  has_many :target_category_positions
  has_many :target_type_positions
  has_many :target_types, through: :target_type_positions

end
