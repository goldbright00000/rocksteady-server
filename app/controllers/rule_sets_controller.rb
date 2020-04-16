class RuleSetsController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    product_line = ProductLine.find(params[:product_line_id])
    country = Country.find(params[:region_id])

    target_category =
      if params[:target_kit_id].present?
        TargetKit.find(params[:target_kit_id]).target.target_category
      elsif params[:target_id].present?
        Target.find(params[:target_id]).target_category
      elsif params[:target_category_id].present?
        TargetCategory.find(params[:target_category_id])
      else
        render_error('Please specify a TargetKit, Target or TargetCategory.') and return
      end

    rule_sets = product_line.applicable_rule_sets(country, target_category).collect do |rs|
      rs.attached_product_line_id = params[:product_line_id]
      rs
    end

    render(json: rule_sets, root: :rule_sets)
  end
end
