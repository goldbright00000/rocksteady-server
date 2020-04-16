# OrderKit is Kit being custom made for a customer
class OrderKit
  include ActiveModel::Model
  include ActiveModel::Validations
  extend Rst::OrderModelsAdditions::ClassMethods

  validates :product_line_id, presence: true

  attr_accessor :order_kit_positions, :order, :customer_geo_location

  def initialize(attributes = {})
    super
    @order_kit_positions ||= Rst::OrderModelsAdditions::HasManyCollection.new
  end

  belongs_to :product_line
  belongs_to :target_kit
  belongs_to :target_category
  belongs_to :manufacturer
  belongs_to :target
  belongs_to :rule_set
  belongs_to :use_category
  belongs_to :use
  belongs_to :regulation


  def order_kit_position_features
    (order_kit_positions.map &:order_kit_position_features).flatten
  end

  def features_available_on_at_least_one_position
    order_kit_position_features.uniq(&:name)
  end

  def order_kit_positions=(positions)
    positions.each { |p| order_kit_positions << p }
  end

  attr_accessor :all_colours, :designer_colour_ids, :kit_components,
                :kit_shapes, :list_of_regulated_colours,
                :list_of_unregulated_features, :competing_region_id

  def target_kit_with_components?
    target_kit.present? && target_kit.kit_components.present?
  end

  def display_map
    target_kit_with_components? ? target_kit.display_map : target_category.display_map
  end

  def target_icon_ids
    unless @target_icon_ids.present?
      @target_icon_ids = TargetIcon.icon_set(target_kit_id, target_id, manufacturer_id, target_category_id, product_line.target_type_id)
    end

    @target_icon_ids
  end

  def prompted_features
    features_available_on_at_least_one_position
      .select(&:prompt?)
      .select(&available_on_this_product_line)
      .reject(&pre_assigned_by_the_regulation)
      .sort  { |x,y| x.display_order <=> y.display_order }
  end

  def linked_features
    features_available_on_at_least_one_position
      .select(&:linked?)
      .sort  { |x,y| [ (x.ui_prompt? ? 1 : 2), x.display_order ] <=> [ (y.ui_prompt? ? 1 : 2 ), y.display_order ] }
  end

  def available_on_this_product_line
    features_ids = Feature.available_on_product_line(product_line).map &:id
    Proc.new { |f| features_ids.include?(f.feature.id) }
  end

  def pre_assigned_by_the_regulation
    regulation.nil? ?  ->(_) { false } : Proc.new { |f| regulation.fixed_text_features.include?(f.feature.id) }
  end

  # true if no position has a real shape
  def has_no_real_shapes?
    return !order_kit_positions.any? do |okp|
       okp.shape != okp.target_category_position.shape
    end
  end

  def build_designer_colour_ids
    if @designer_colour_ids.blank?
      colour_ids = colour_palette.colour_ids

      colour_ids << ComplementaryColour.where(colour_id: colour_ids).pluck(:complementary_colour_id)
      colour_ids << ContrastingColour.where(colour_id: colour_ids.flatten.uniq).pluck(:contrasting_colour_id)

      colour_ids << regulation.colour_ids if regulated?

      @designer_colour_ids = colour_ids.flatten.uniq.compact.sort
    end

    @designer_colour_ids
  end

  def font_palette
    if @font_palette.blank?
      [target, manufacturer, target_category].each do |source|
        if source && source.font_palette && source.font_palette.font_palette_fonts.present?
          @font_palette = source.font_palette
          break
        end
      end
    end

    @font_palette
  end

  def font_ids
    if @font_ids.blank?
      font_ids = font_palette.font_ids
      font_ids << regulation.font_ids if regulated?
      @font_ids = font_ids.flatten.uniq.compact
    end

    @font_ids
  end

  def colour_palette
    if @colour_palette.blank?
      [target_kit, manufacturer, target_category].each do |source|
        if source && source.colour_palette && source.colour_palette.colour_palette_colours.present?
          @colour_palette = source.colour_palette
          break
        end
      end
      @colour_palette = ColourPalette.none unless @colour_palette
    end

    @colour_palette
  end

  def apply_customer_prompted_feature_values(prompted_feature_values)
    (prompted_features.map &:feature).each do |feature|
      value = prompted_feature_values[feature.name.symbolize]
      if value.present?
        order_kit_position_features.each do |position_feature|
          position_feature.value = value if position_feature.feature_id == feature.id
        end
      end
    end
  end

  # TODO: The nationality isn't a general comcept, so it needs to change.
  def user_flag
    prompted_features.detect {|p| break p if p.name == "User Flag" }
  end

  # Used to set a flag to indicate to client that it should display a flag warning
  def target_category?
    target_kit.nil? || has_no_real_shapes?
  end

  def regulated?
    regulation.present?
  end

  def id; nil; end
end
