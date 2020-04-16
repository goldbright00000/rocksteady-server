class TargetCategoriesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    @product_line = ProductLine.find(params[:product_line_id])
    @target_categories = @product_line.target_categories.map do |tc|
      tc.attached_product_line_id = params[:product_line_id]
      tc
    end
    render json: @target_categories, root: :target_categories
  end
end
