class TargetsController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  before_action :load_targets

  def index
    if @product_line
      @targets = @product_line.targets
      if @manufacturer
        @targets = @targets.where(manufacturer_id: @manufacturer.id)
      end
    end

    render json: @targets, root: :targets
  end


  def show
    render json: Target.find(params[:id])

  rescue ActiveRecord::RecordNotFound => e
    render(:json => { error: e.message}, status: :not_found)
  end

  def load_targets
    @product_line = ProductLine.find(params[:product_line_id])
    @manufacturer = Manufacturer.find(params[:manufacturer_id]) if params[:manufacturer_id].present?
  end
end
