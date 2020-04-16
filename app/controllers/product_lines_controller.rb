class ProductLinesController < ApiController
  def index
    render json: ProductLine.includes(:kit_type, :target_type, :interview_icon)
  end

  def show
    render json: ProductLine.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    @error = e.message
    render(:json => { error: @error }, status: :not_found)
  end
end
