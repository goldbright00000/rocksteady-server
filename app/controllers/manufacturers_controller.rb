class ManufacturersController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    render json: ProductLine.find(params[:product_line_id]).manufacturers.includes(:interview_icon), root: :manufacturers
  end
end
