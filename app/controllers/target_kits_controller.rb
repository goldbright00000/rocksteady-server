class TargetKitsController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new {|e| render_error(e.message) }

  def index
    @target = Target.find(params[:target_id])
    @target_kits = @target.target_kits.order('qualifying_data DESC')
    render json: @target_kits, root: :target_kits
  end


  def show
    render json: TargetKit.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    @error = e.message
    render(:json => { error: @error }, status: :not_found)
  end
end
