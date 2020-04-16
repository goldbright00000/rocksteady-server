class UseCategoriesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    render_error("Please specify a Target or TargetCategory") and return unless required_params?
    render json:  UseCategory.where(id: source.available_use_category_ids(rule_set)), root: :use_categories
  end

  private

  def source
    if params[:target_id].present?
      Target.find(params[:target_id])
    elsif params[:target_category_id].present?
      TargetCategory.find(params[:target_category_id])
    end
  end

  def rule_set
    RuleSet.find(params[:rule_set_id])
  end

  def required_params?
    params.key?(:rule_set_id) && (params.key?(:target_id) || params.key?(:target_category_id))
  end
end
