class GraphicsController < ApiController
  before_action :set_cache_header

  def index
    offset,limit = pagination_params
    render json: icons_with_includes.limit(limit).offset(offset), root: :graphics, meta:{ total: icons_with_includes.count }
  end

  def index_by_tags
    render(json: [], root: :graphics, status: 404)  and return if params[:tags].empty?

    offset,limit = pagination_params
    icons = icons_with_includes.tagged_with(tags)

    render json: icons.limit(limit).offset(offset), root: :graphics ,meta: { total: Icon.from(icons).count }
  end

  def show
    ids = params[:ids]
    ids = [params[:id]] if params.key?(:id)
    icons = icons_with_includes.where('icons.id in(?)', ids)

    return ids_not_found unless icons.count == ids.size
    render json: icons, root: :graphics
  end

  private

  def icons_with_includes
    Icon.preload(:icon_tags)
  end

  def pagination_params
    offset = params[:offset].present? ? params[:offset].to_i : 0
    limit  = params[:limit].present? ? params[:limit].to_i : 32
    [offset, limit]
  end

  def ids_not_found
    render json: [], root: :graphics, status: 404
  end

  # special care for multibyte characters
  # using ActiveSupport::Multibyte::Chars module
  def tags
    params[:tags].map { |t| t.mb_chars.downcase.to_s.strip }
  end
end
