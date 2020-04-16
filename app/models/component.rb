# Component represents the underlying physical piece of plastic available for a
# Position in a Kit and links the Shapes available for that Position.
class Component < ActiveRecord::Base

  belongs_to :colour_palette
  belongs_to :curvature
  belongs_to :default_shape, class_name: 'Shape'
  belongs_to :manufacturer
  belongs_to :position
  belongs_to :surface_material
  belongs_to :texture
  has_many :component_decals
  has_many :decals, through: :component_decals
  has_many :kit_components
  has_many :kits, through: :kit_components
  has_many :shapes, through: :kit_components

  default_scope {
    includes(:colour_palette)
  }

end
