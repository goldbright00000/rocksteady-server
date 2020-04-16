class PromptedFeaturesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    render_error('Please specify a TargetKit, Target, or TargetCategory.') and return unless valid_params?

    order_kit, msg = BuildOrderKit.call(params).create

    render_error(msg) and return if msg.present?

    render(json: { prompted_features: order_kit.prompted_features.map {|f| { name: f.name, display_name: f.display_name, default_value: f.value}}} )
  end

  private

  def valid_params?
    params[:target_kit_id].present? || params[:target_id].present? || params[:target_category_id].present?
  end
end
