class BuildThemePositionAndFeatures
  attr_reader :order_kit, :theme_id

  def initialize(theme_id:)
    @theme_id = theme_id
  end

  def call(order_kit)
    @order_kit = order_kit
    positions = build_positions
    apply_features(positions)
    positions
  end

  protected

  def apply_features(positions)
    theme.theme_linked_features.each do |f|
      position = positions.detect {|p| p.target_category_position_id == f.target_category_position_id and break p }

      position.order_kit_position_features << OrderKitPositionFeature.instantiate_for_type(f.feature, order_kit_position: position,
               feature_id: f.feature.id, allowed_by_the_regulation: allowed_by_the_regulation(f.feature, position))
    end
  end

  def build_positions
    theme.target_category_positions.map do |tc_position|
      OrderKitPosition.new(order_kit: order_kit, target_category_position: tc_position)
    end
  end

  private

  def theme
    @theme ||= Theme.includes(theme_linked_features: [:feature, :target_category_position] ).find(theme_id)
  end


  def regulated_features
    return [] unless order_kit.regulated?
    @regulated_features ||= RegulationFeature.where(regulation_id: order_kit.regulation.id).all
  end

  def allowed_by_the_regulation(feature, position)
    return false if feature.presence_regulated? && !order_kit.regulated?
    return false if feature_prohibited_by_regulation?(feature, position)
    return false if feature_not_proscribed_by_regulation?(feature, position)

    return true
  end

  def feature_prohibited_by_regulation?(feature, position)
    regulated_features.any? do |rf|
      rf.position_id == position.position_id && rf.feature_id == feature.id && rf.prohibited?
    end
  end

  def feature_not_proscribed_by_regulation?(feature, position)
    return false unless feature.proscribed?

    regulated_features.any? do |rf|
      rf.position_id == position.position_id && rf.feature_id == feature.id && !rf.prohibited?
    end
  end

  def regulated_features_for_unregulated_kits
    order_kit.regulated? ?  ->(_) { false } : Proc.new { |f| f.feature.presence_regulated? }
  end

end
