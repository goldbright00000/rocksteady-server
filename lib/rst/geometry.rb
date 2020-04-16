require 'bigdecimal'

module Rst
  class Geometry

    def self.bounding_box_dimensions(inner_rectangle_width, inner_rectangle_height, rotate_in_degrees)
      width    = BigDecimal.new inner_rectangle_width
      height   = BigDecimal.new inner_rectangle_height
      angle    = BigDecimal.new((rotate_in_degrees * Math::PI) / 180, 5) # convert to radians

      # rectangle centre coords
      centre_x = width/2
      centre_y = height/2

      corners = [[0, 0], [0, height], [width, height], [width, 0]]

      corners.map! do |points|
        # translate rectangle centre to origin
        temp_x    = points[0] - centre_x
        temp_y    = points[1] - centre_y

        # do rotation
        rotated_x = (temp_x * Math::cos(angle)) - (temp_y * Math::sin(angle))
        rotated_y = (temp_x * Math::sin(angle)) + (temp_y * Math::cos(angle))

        # translate rectangle centre back to original place
        points[0] = rotated_x + centre_x
        points[1] = rotated_y + centre_y

        points
      end

      min_x, max_x = corners.minmax_by { |p| p[0] }.map { |p| p[0] }
      width        = max_x - min_x # distance in single dimension
      min_y, max_y = corners.minmax_by { |p| p[1] }.map { |p| p[1] }
      height       = max_y - min_y # distance in single dimension

      [
          BigDecimal.new(width).round(3, :default),
          BigDecimal.new(height).round(3, :default)
      ]
    end

  end

end
