#
# Records the DisplayMapTemplate and the size of the virtual canvas to use for a
# kit's DisplayMap and provides a reference to the positions to be displayed on
# the map.
class DisplayMap < ActiveRecord::Base

  belongs_to :display_map_template
  belongs_to :kit
  has_many :display_map_positions
  has_many :positions, through: :display_map_positions

end
