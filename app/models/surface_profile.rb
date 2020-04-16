# Every Decal has a collection of SurfaceProfiles to which it may be affixed
#
# Parameters are SurfaceMaterial, Texture and Curvature
#
class SurfaceProfile < ActiveRecord::Base

  belongs_to :curvature
  belongs_to :decal
  belongs_to :surface_material
  belongs_to :texture

end
