#
# Each TargetType has a template display map that provides a default visual
# layout for all positions defined on it's targets.  DisplayMapTemplate holds a
# reference to the TargetType and the ProductLine and #build_display_map will
# create a display map for a particular Kit
#
class DisplayMapTemplate < ActiveRecord::Base

  DEFAULT_MARGIN = 25

  belongs_to :kit_type
  belongs_to :target_category
  has_many :display_map_template_positions
  has_many :display_maps


  # Build the generic display_map for a TargetCategory
  def default_map
    unless @map
      layout = calculate_layout(target_category.target_category_positions)
      @map   = DisplayMap.new(width: layout[:width], height: layout[:height])
      layout[:positions].each do |position|
        @map.display_map_positions.build(
            position_id: position[:position_id],
            x:           position[:x],
            y:           position[:y],
            width:       position[:width],
            height:      position[:height],
            rotation:    position[:rotation]
        )
      end
    end
    @map
  end

  protected

  def calculate_layout(source_positions = nil)
    grid, vertical, horizontal   = determine_grid_dimensions(source_positions)
    layout, vertical, horizontal = build_layout_grid(grid, vertical, horizontal)
    layout[:width]               = horizontal.sum + (horizontal.count * (DEFAULT_MARGIN * 2))
    layout[:height]              = vertical.sum + (vertical.count * (DEFAULT_MARGIN * 2))
    layout
  end

  def build_layout_grid(grid, vertical, horizontal)
    layout = {
        positions: []
    }
    grid.each_with_index do |row, row_index|
      row.each_with_index do |column, column_index|
        if column[:width] > 0
          layout[:positions][column[:position_id]] = {
              x:           calculate_position(horizontal, column_index),
              y:           calculate_position(vertical, row_index),
              width:       column[:width],
              height:      column[:height],
              rotation:    column[:rotation],
              position_id: column[:position_id],
              name:        column[:name]
          }
        end
      end
    end
    layout[:positions].compact!
    vertical.compact!
    horizontal.compact!
    return layout, vertical, horizontal
  end

  def determine_grid_dimensions(source_positions)
    grid       = Array.new(rows) {
      Array.new(columns) {
        { width: 0, height: 0, rotation: 0, position: nil }
      }
    }
    vertical   = Array.new(rows)
    horizontal = Array.new(columns)

    source_positions.each do |source_position|
      # source_position > target category position
      template_position = display_map_template_positions.where(position_id: source_position.position_id).first!

      # look at every shape and pick the highest height and width
      box               = {}
      # TODO: BM revisit it, size shouldn't cause any issue here
      if source_position.shapes.count > 0
        source_position.shapes.each do |shape|
          new_box           = template_position.box_details(grid[template_position.y][template_position.x], shape)
          box[:rotation]    ||= new_box[:rotation]
          box[:position_id] ||= new_box[:position_id]
          box[:width]       = new_box[:width] if box[:width].blank? or box[:width] < new_box[:width]
          box[:height]      = new_box[:height] if box[:height].blank? or box[:height] < new_box[:height]
        end
      else
        box = template_position.box_details(grid[template_position.y][template_position.x], source_position.default_shape)
      end

      grid[template_position.y][template_position.x] = box
      vertical[template_position.y]                  = [box[:height], vertical[template_position.y] || 0].max
      horizontal[template_position.x]                = [box[:width], horizontal[template_position.x] || 0].max
    end

    return grid,
        vertical,
        horizontal
  end

  def calculate_position(dimensions, position)
    return 0 if dimensions[position].blank?

    value = DEFAULT_MARGIN
    (0..position - 1).each do |column|
      if dimensions[column]
        value += dimensions[column] + (DEFAULT_MARGIN * 2)
      end
    end

    (value + dimensions[position] / 2).round(3)
  end

end
