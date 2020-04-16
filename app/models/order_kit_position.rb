class OrderKitPosition
  include ActiveModel::Model
  include ActiveModel::Validations
  extend Rst::OrderModelsAdditions::ClassMethods

  def initialize(attributes = {})
    super
    @order_kit_position_features ||= Rst::OrderModelsAdditions::HasManyCollection.new
  end

  attr_accessor :order_kit

  def order_kit_id
    order_kit.id
  end

  belongs_to :target_category_position
  belongs_to :shape
  belongs_to :kit_component
  belongs_to :display_map_position
  belongs_to :decal

  attr_accessor :quantity, :created_at, :updated_at, :order_kit_position_features, :position_id

  delegate :regulation,
           :rule_set,
           :customer_geo_location,
           :designer_colour_ids,
           :all_colours,
           :font_ids,
           :kit_components,
           :kit_shapes,
           :list_of_regulated_colours,
           :list_of_unregulated_features,
           to: :order_kit

  validates :target_category_position_id,
            presence:   true
            #uniqueness: { scope: :order_kit_id }

  delegate :position,
           :position_id,
           to: :target_category_position

  validates :shape_id,
            presence: true

  validates :decal_id,
            presence: true


  delegate :x, :y, :top, :left, :width, :height, :rotation,
           to: :display_map_position

  validates :quantity,
            numericality: true

  #has_one :order_kit_position_output

  # has_many :order_kit_position_features,
  #          inverse_of: :order_kit_position

  attr_accessor :background_fill

  def decal_ids
    target_category_position.decal_ids(regulation)
  end

  def map
    if display_map_position.present?
      display_map_position
    else
      # this is very smelly - There should probably be a TargetCategory default display map...
      order_kit
          .target_category
          .display_map
          .display_map_positions
          .select { |p| p.position_id.eql?(position_id) }.first
    end
  end

  def is_regulated?
    order_kit_position_features.each do |f|
      return true if f.regulated?
    end

    false
  end

  def get_related_position_id(position_id)
    dmtp = order_kit
               .target_category
               .display_map_template
               .display_map_template_positions
               .find_by_position_id(position_id)

    dmtp.present? ? dmtp.related_position_id : nil
  end

  def as_hash
    feature_ids   = build_features_hashes
    component_ids = build_components_collections

    hash = {
        kit_id:        order_kit_id,
        id:            position_id,
        name:          position.name,
        is_regulated:  is_regulated?,
        x:             map.x.to_f,
        y:             map.y.to_f,
        width:         map.width.to_f,
        height:        map.height.to_f,
        rotation:      map.rotation,
        grouping:      get_related_position_id(position_id),
        component_id:  component_source.component_id,
        component_ids: component_ids,
        feature_ids:   feature_ids,
        alternative_shapes_ordered: component_source.alternative_shapes_ids
    }

    return hash, @features, @properties
  end

  #
  # Each Position may have a collection of Components & related Shapes associated
  # with it.  Add the Components and Shapes for this position to those for the Kit.
  #
  def build_components_collections
    component_ids = []

    component_source.positions_components.each do |position_component|
      key = "#{position_component.component_id}-#{position_id}"

      unless kit_components[key]
        component_ids << position_component.component_id
        kit_components[key] = position_component.as_hash(decal_ids)
      end

      position_component.shapes.each do |shape|
        if kit_shapes[shape.id]
          unless kit_shapes[shape.id][:component_ids].include?(position_component.component_id)
            kit_shapes[shape.id][:component_ids] << position_component.component_id
          end
        else
          kit_shapes[shape.id]                 = shape.as_hash(position_component.decal_ids & decal_ids, apply_percentage_discount:  customer_geo_location.discount )
          kit_shapes[shape.id][:component_ids] = [position_component.component_id]
        end
      end
    end

    component_ids
  end

  def component_source
    kit_component || target_category_position
  end

  def ordered_position_features
    order_kit_position_features.sort {|x,y| x.feature_id <=> y.feature_id }
  end

  def build_features_hashes
    position_feature_ids = []
    @features            = []
    @properties          = []
    @background_fill     = nil

    ordered_position_features.includes({ :regulation_feature => :regulation_feature_properties, :feature => :feature_type}).each do |feature|

      feature_hash, feature_properties = feature.as_hash
      if feature_hash.present?
        position_feature_ids << feature_hash[:link]
        @features << feature_hash
        @properties << feature_properties
        @background_fill ||= feature_properties.select { |p| p[:name].eql?('Fill') }.first
      end
    end
    @features.flatten!
    @properties.flatten!

    if @background_changed
      propogate_background_colour_change
    end

    position_feature_ids
  end

  def default_background_colour_id
    if kit_component.present?
      kit_component.default_background_colour_id
    else
      order_kit.colour_palette.colour_ids.first
    end
  end

  def contrasting_colour_id(colour_id)
    all_colours.select { |c| c.id.eql?(colour_id) }.first.contrast_id
  end

  #
  # In some instances a regulated Text Feature can specify a Fill that is the
  # same colour as an unregulated Background Fill.  The Background Fill is then
  # changed to be the contrasting colour of the Feature's Fill.
  #
  # By default the Fill property for all Text Features is set to be the
  # contrasting colour of the Background's Fill.  As that Fill has changed all
  # Text Feature's using the default Fill that have not been specified by a Rule
  # need to change so that they don't 'disappear' into the Background.
  #
  # TODO: ? Strokes on the affected Features should probably also be changed to reflect the change in Fill colour
  #       The Client currently corrects the colour when the first stroke is turned on
  def change_background_colour(colour_id)
    background_fill[:value] = colour_id
    @background_changed     = true
  end

  def propogate_background_colour_change

    colour_id = contrasting_colour_id(background_fill[:value])

    @features.select { |f| f[:type].eql? 'Text' }.each do |feature|
      fill_property = feature[:attribute_ids].min
      fill          = @properties.select { |p| p[:link].eql?(fill_property) }.first
      if fill[:rule].empty?
        fill[:value] = colour_id
      end
    end

  end
end
