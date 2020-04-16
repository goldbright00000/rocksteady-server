class OrderKitPositionFeature
  include ActiveModel::Model
  include ActiveModel::Validations
  extend Rst::OrderModelsAdditions::ClassMethods

  attr_accessor :order_kit_position, :allowed_by_the_regulation

  attr_accessor :position_id, :x, :y, :angle, :scale, :z_index,
                :fill_colour_id, :text, :font_size, :font_id,
                :text_alignment, :letter_spacing, :line_height,
                :stroke_style_1, :stroke_style_2, :stroke_style_3,
                :stroke_style_4, :stroke_width_1, :stroke_width_2,
                :stroke_width_3, :stroke_width_4, :flip_x, :flip_y,
                :stroke_internal_1, :stroke_front_1, :created_at, :updated_at

  validates :order_kit_position_id,
            presence: true

  delegate :order_kit,
           :regulation,
           :rule_set,
           :all_colours,
           :designer_colour_ids,
           :default_background_colour_id,
           :contrasting_colour_id,
           :background_fill,
           :font_ids,
           :shape,
           :list_of_regulated_colours,
           :list_of_unregulated_features,
           to: :order_kit_position


  validates :feature_id, presence: true

  delegate :prompt?, :linked?, :display_name, :display_order, :name, :presence_regulated?, to: :feature

  belongs_to :feature

  belongs_to :regulation_feature
  belongs_to :feature_placement


  def value
    raise NotImplementedError.new("Value method should be implemeted")
  end

  def ui_prompt?
    prompt? && allowed_by_the_regulation
  end

  def self.instantiate_for_type(feature, *params)
    name = feature.name.gsub(' ', '')
    name += "Feature"

    # It fixes the designer added features
    name = 'DesignerAddedTextFeature' if name =~ /DesignerAddedText.*Feature/
    name = 'DesignerAddedIconFeature' if name =~ /DesignerAddedIcon.*Feature/

    begin
      klass = ActiveSupport::Dependencies.constantize(name)
    rescue NameError => ex
      raise ex unless feature.type
      types = { 'Icon' => 'DesignerAddedIconFeature',
                'Text' => 'TextFeature'}

      klass = ActiveSupport::Dependencies.constantize(types.fetch(feature.type, name))
    end

    klass.new(*params)
  end

  def regulated?
    regulation_feature.present?
  end

  def regulation_placement
    regulation_feature.present? ? regulation_feature.placement : nil
  end

  def as_hash
    @feature_hash = {
        id:                        feature_id,
        link:                      "#{position_id}_#{feature_id}",
        position_id:               position_id,
        type:                      feature.client_type,
        name:                      feature.name,
        z_index:                   z_index,
        linked:                    feature.linked,
        user_specific_information: feature.user_specific_information,
        attribute_ids:             []
    }

    build_properties

    if @empty_feature.present?
      return nil, nil
    else
      return @feature_hash, @properties
    end
  end

  def build_properties
    @properties = []
  end

  # @param [Property] property
  # @param [Hash] values
  # @return [Hash]
  def add_property(property, values)
    hash = {
        id:          property.id,
        link:        "#{position_id}-#{feature_id}-#{property.id}",
        feature_id:  feature_id,
        position_id: position_id,
        name:        property.name,
    }.merge(values)
    @feature_hash[:attribute_ids] << hash[:link]
    @properties << hash
    hash
  end

  # Default to 0, regulation may override
  def stroke_width(property)
    stroke_width_rule = []

    if regulated?
      stroke_width      = send(property.field_name) || regulation_feature.stroke_width(property.id)
      stroke_width_rule = stroke_width
    else
      stroke_width = send(property.field_name)
    end

    stroke_width ||= 0

    {
        value: stroke_width,
        rule:  stroke_width_rule
    }
  end

  # These are here until we switch from top/left to x/y for FAM
  def top
    y
  end

  def left
    x
  end

  def fill_colour_id
    #v = read_attribute :fill_colour_id
    v = @fill_colour_id
    v = v.sub(/FAMREG/, '') if fill_colour_id_fam_regulated?

    v.present? ? v.to_i : v # convert to_i
  end

  def fill_colour_id_fam_regulated?
    # v = read_attribute :fill_colour_id
    v = @fill_colour_id

    v.present? and v.is_a?(String) and v.start_with?('FAMREG')
  end
end
