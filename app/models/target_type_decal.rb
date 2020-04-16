# Each TargetType has a predetermined list of Decals available.
class TargetTypeDecal < ActiveRecord::Base

  belongs_to :target_type
  validates :target_type_id,
            presence: true

  belongs_to :decal
  validates :decal_id,
            presence: true,
            uniqueness: { scope: :target_type_id }
end
