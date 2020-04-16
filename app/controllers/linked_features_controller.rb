class LinkedFeaturesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    render_error('Please specify a TargetKit, Target, or TargetCategory.') and return unless valid_kit_params?
    render_error('Please specify Theme.') and return unless valid_theme_param?

    theme_params = {regulation_id: theme.regulation.id, use_id: theme.regulation.use_id, use_category_id: theme.regulation.use_category_id, rule_set_id: theme.regulation.rule_set_id } if theme.regulation

    order_kit, msg = BuildOrderKit.call(permitted_params.reverse_merge(theme_params)).create(position_and_features_builder: BuildThemePositionAndFeatures.new(theme_id: theme.id))

    render_error(msg) and return if msg.present?

    render(json: { linked_features: order_kit.linked_features.map {|f| { name: f.name, display_name: f.display_name, default_value: f.value, prompt: f.ui_prompt? }}} )
  end

  private

  def permitted_params
    params.permit(:product_line_id, :target_id, :manufacturer_id, :target_category_id, :target_kit_id, :theme_id, :use_id, :use_category_id,:rule_set_id)
  end

  def theme
    @theme ||= Theme.find_by_external_id(params[:theme_id]) or render_error("Invalid Theme")
  end

  def valid_theme_param?
    params[:theme_id].present?
  end

  def valid_kit_params?
    params[:target_kit_id].present? || params[:target_id].present? || params[:target_category_id].present?
  end
end
