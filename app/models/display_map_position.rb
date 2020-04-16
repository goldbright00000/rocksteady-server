# Display maps are used to defined a schematic view
# at the component selection stage. DisplayMapPositionSpecification
# defines some properties for each related PositionSpecification.
# These properties are the coordinates of where that given PositionSpecification
# should appear in the overall schematic.
class DisplayMapPosition < ActiveRecord::Base

  belongs_to :display_map
  belongs_to :position

end
