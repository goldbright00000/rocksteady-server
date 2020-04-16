class ColoursController < ApiController
  before_action :set_cache_header

  def index
    render json: colours
  end

  def show
    colour = colours.one_by_display_rgb(params[:rgb])
    return head(:not_found) unless colour.present?
    render json: colour
  end


  private

  def colours
    Colour.includes(contrasting_colours: [], colour_group: [:default_colour], complementary_colours: [])
  end
end
