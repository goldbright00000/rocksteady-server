# KitComponents link Component, Position, Kit and Shape
class KitComponent< ActiveRecord::Base

  belongs_to :component
  belongs_to :kit
  belongs_to :position
  belongs_to :shape
  delegate :colour_palette, :manufacturer, to: :component

  def themes
    shape.themes.distinct
  end

  def positions_components
    kit.kit_components.where(position_id: position_id).order('kit_components.id')
  end

  def alternative_shapes_ids
    positions_components.map &:shape_id
  end

  def shapes
    positions_components.where(component_id: component_id).includes(:shape).map {|kc| kc.shape }
  end

  def component_ids
    positions_components.pluck(:component_id).uniq
  end

  def alternative_components
    positions_components.where('kit_components.component_id <> ?', component_id)
  end

  def default_background_colour_id
    colour_palette.colour_ids.first
  end

  def shape_component_ids
    kit.kit_components.where(shape_id: shape_id).distinct.pluck(:component_id)
  end

  def shape_decal_ids
    ComponentDecal.where(component_id: shape_component_ids).distinct.pluck(:decal_id)
  end

  def decal_ids
    component.component_decals.pluck(:decal_id)
  end

  def shape_prices(available_decal_ids)
    shape.decal_prices(shape_decal_ids & available_decal_ids)
  end

  def as_hash(available_decal_ids)
    {
        id: component_id,
        position_id: position_id,
        name: name,
        manufacturer_id: manufacturer.id,
        shape_id: component.default_shape_id,
        decal_ids: decal_ids & available_decal_ids
    }
  end

  #
  # Used in DecalLoadJob
  #
  def component_decal_ids
    component.component_decals.pluck(:decal_id)
  end

  #
  # Used in DecalDiscrepanciesReportJob
  #
  def connected_kit_components
    kit.kit_components
    .where.not(id: id)
    .where.not(position_id: position_id)
    .where(shape_id: alternative_shape_ids)
    .joins(:shape)
    .where('shapes.multiple_positions = ?', true)
    .distinct
  end

  def alternative_shape_ids
    kit.kit_components
    .where(component_id: component_id)
    .where('kit_components.id <> ?', id)
    .pluck(:shape_id)
  end

  def name
    [component.manufacturer.name, component.name || 'Stock'].join(' - ')
  end

end
