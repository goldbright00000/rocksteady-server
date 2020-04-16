# A given Component may be available for purchase printed on different decal,
# One of the decals is selected by default when creating a Kit.
class ComponentDecal < ActiveRecord::Base

  belongs_to :component
  belongs_to :decal

  default_scope { joins(:decal).order('decals.price_per_m2 DESC') }

end
