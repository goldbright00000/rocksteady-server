class TagsController < ApiController
  def index
    if params[:filter] == 'suggestions' && params[:type] == 'graphics'
      render json: fetch_suggestions(params[:type])
    else
      render json: "Unable to process request.".to_json
    end
  end

  private

  # TODO: QH temporary solution for maintaining tag cloud information.
  def fetch_suggestions(type)
    tags_config = Rails.root.join('config/tags.yaml')

    if File.exist? tags_config
      tags = YAML.load_file(tags_config)['tag_suggestions']
      tag_array = tags.map {|t| {:tag => t, :type => type}}
    else
      tag_array = []
    end

    {:tags => tag_array}
  end
end
