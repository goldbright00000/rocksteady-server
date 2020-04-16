# Each TargetCategory has a collection of Positions for each KitType.
# Each of these has associated collections of Features, Shapes and Decals.
class TargetCategoryPosition < ActiveRecord::Base

  belongs_to :default_shape, class_name: 'Shape'
  belongs_to :kit_type
  belongs_to :position
  belongs_to :target_category

  delegate :name, to: :position

  has_many :target_category_shapes
  has_many :shapes, ->() { order('target_category_shapes.id') }, through: :target_category_shapes

  default_scope { includes :target_category }


  def available_decal_ids
    unless @available_decal_ids
      filter = SurfaceProfile
      .joins(:decal => :target_type_decals)
      .where("target_type_decals.decal_id = decals.id AND target_type_decals.target_type_id = #{target_category.target_type_id}")
      .where(surrounding_environment_id: surrounding_environment_id)
      .where("decals.min_ot <= #{min_ot}
        AND decals.max_ot >= #{max_ot}")
      if uv
        filter = filter.where("decals.uv = true")
      end
      if non_slip
        filter = filter.where("decals.non_slip = true")
      end
      @available_decal_ids = filter.pluck(:decal_id).uniq
    end
    @available_decal_ids
  end

  def decal_ids(regulation = nil)
    # A regulation may prescribe the Finish(es) to be used on Decals
    if regulation
      filtered = Decal.where(id: available_decal_ids)
      regulation_finishes = regulation.regulation_finishes.where(position_id: position_id)
      if regulation_finishes.present?
        # Luminous & Opacity are the same for each item in the RegaultionFinishes collection
        regulation_finish = regulation.regulation_finishes.first
        filtered = filtered.where(luminous: regulation_finish.luminous) unless regulation_finish.luminous.nil?
        filtered = filtered.where(opacity_id: regulation_finish.opacity_id) unless regulation_finish.opacity_id.nil?

        # TODO: BM revisit it, .size should cause any issue here
        # There may be more than one Finish specified (e.g. Matt & Satin)
        if regulation.regulation_finishes.count > 1
          finishes = regulation.regulation_finishes.pluck(:finish_id).compact.uniq
        else
          finishes = [regulation_finish.finish_id].compact
        end
        filtered = filtered.where(finish_id: finishes) if finishes.present?
      end
      filtered.pluck(:id)
    else
      available_decal_ids
    end
  end

  def decals(regulation = nil)
    Decal.where(id: decal_ids(regulation))
  end

  def operating_environment
    [
        Decal::SURROUNDING_ENVIRONMENTS[surrounding_environment_id],
        [
            uv? ? 'UV' : '',
            non_slip? ? 'Non-slip' : ''
        ].join(','),
        min_ot,
        max_ot
    ].join('/')
  end

  #
  # For TargetCategoryKits make the TCP look like a KitComponent
  #
  def component_id
    position_id
  end

  def shape
    default_shape
  end

  def alternative_shapes_ids
    shapes.map &:id
  end

  def positions_components
    [self]
  end

  def as_hash(available_decal_ids)
    {
        id: position_id,
        position_id: position_id,
        name: "#{target_category.name} - Stock",
        manufacturer_id: Manufacturer::MOTOCAL.call.id,
        shape_id: default_shape_id,
        decal_ids: available_decal_ids
    }
  end

end
