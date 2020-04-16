require 'bigdecimal'

#
# Records the x,y co-ordinates on the grid and the rotation of the bounding box
# for the Position on the DisplayMapTemplate
class DisplayMapTemplatePosition < ActiveRecord::Base

  belongs_to :display_map_template
  belongs_to :position

  def box_details(grid_position, shape)
    #
    #   Some kits do not specify actual shapes so we
    #   assume that we want the shapes to be packed
    #   as close together as possible.
    #

    editor_width = 0
    editor_height = 0

    if shape
       editor_width = shape.editor_width
       editor_height = shape.editor_height
    end

    case
      when rotation == 90 || rotation == 270
        width  = [editor_height, grid_position[:width]].max
        height = [editor_width, grid_position[:height]].max
      when rotation == 180 # no change
        width  = [editor_width, grid_position[:width]].max
        height = [editor_height, grid_position[:height]].max
      else # calculate bounding box
        bb_width, bb_height = Rst::Geometry::bounding_box_dimensions editor_width, editor_height, rotation
        width               = [bb_width, grid_position[:width]].max
        height              = [bb_height, grid_position[:height]].max
    end

    {
        rotation:    rotation,
        position_id: position_id,
        width:       width,
        height:      height
    }
  end

end
