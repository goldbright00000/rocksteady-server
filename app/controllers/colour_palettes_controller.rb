class ColourPalettesController < ApiController

  def index
    # TODO: 20130910 mjg - the meaning of this has changed, this will be the Edition of the Target
    #@colour_palettes = ColourPalette.where(id: TargetKit.find(params[:target_kit_id]).colour_palette_id).all
    @colour_palettes = ColourPalette.where(id:1)
    render json: @colour_palettes
  end

end
