class ComplementaryColour < ActiveRecord::Base
  belongs_to :colour
  belongs_to :complementary_colour
end
