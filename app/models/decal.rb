# Materials on which the Shapes that make up a Kit are printed.
class Decal < ActiveRecord::Base

  FINISHES = {
      1 => 'Gloss',
      2 => 'Matt',
      3 => 'Satin',
      1000 => 'Test'
  }

  OPACITIES = {
      1 => 'Clear',
      2 => 'Light Grey',
      3 => 'Dark Grey'
  }

  SURROUNDING_ENVIRONMENTS = {
      1 => 'Indoor',
      2 => 'Outdoor',
      3 => 'Sea Water',
      4 => 'Water'
  }

  has_many :component_decals
  has_many :components, through: :component_decals
  has_many :order_kit_positions
  has_many :surface_profiles
  has_many :target_type_decals

  def self.default
    # The most expensive as it should cover anything?
    order('price_per_m2 DESC').first
  end
end
