class ContrastingColour < ActiveRecord::Base

  belongs_to :colour
  belongs_to :contrasting_colour, class_name: 'Colour'
end
