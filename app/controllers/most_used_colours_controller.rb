class MostUsedColoursController < ApiController

  rescue_from 'MostUsedColours::ImageMagickUnExpectedOutputError' do |e|
    logger.error "#{e}"
    unprocessable_entity
  end

  def index
    unprocessable_entity and return unless valid_image?

    colours = MostUsedColours.new(file: params["image"].tempfile.path).(limit: params.fetch(:limit, 5).to_i)
      .map {|c| { rgb: c.rgb.to_s, pixels: c.pixels.to_i, lab: c.lab } }

    render json: json(colours: colours)
  end

  private

  def valid_image?
    params.key?(:image) && valid_image_content_types.include?(params[:image].content_type)
  end

  def json(colours: [])
    { most_used_colours: colours }
  end

  def valid_image_content_types
    %w(image/jpeg image/png image/svg+xml)
  end

  def unprocessable_entity
    render(:json => json, status: :unprocessable_entity)
  end
end
