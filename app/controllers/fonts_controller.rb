class FontsController < ApiController
  before_action :set_cache_header

  def index
    render json: Font.all, only: [:id, :name]
  end

  def show
    if params[:ids].present?
      fonts = Font.where('id in(?)', params[:ids])

      if fonts.size == params[:ids].size
        render json: fonts
      else
        render json: [], root: :fonts, status: 404
      end
    else
      render json: [], root: :fonts, status: 404
    end
  end
end
