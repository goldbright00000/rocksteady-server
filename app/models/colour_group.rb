class ColourGroup < ActiveRecord::Base
  has_many :colours
  belongs_to :default_colour, class_name: 'Colour', foreign_key: :default_colour_id
end
