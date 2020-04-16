class ThemesController < ApplicationController
  def index
    return head :unprocessable_entity if missing_params?

    themes = Theme.by_query_params(params)

    render json: Theme.by_query_params(params),
           meta: metadata(themes),
           root: :themes


  rescue ActiveRecord::RecordNotFound
    return head :not_found
  end

  private

  def metadata(themes)
    {}.tap do |meta|

    meta[:ordered_categories] = themes.map {|t| t.category }
                       .uniq
                       .sort_by(&:spreadsheet_order)
                       .map(&:name)

    meta[:ordered_filters] = themes.map {|t| t.theme_tags }
                       .flatten
                       .map(&:category)
                       .uniq
                       .sort_by(&:spreadsheet_order)
                       .map(&:name)

    end
  end

  # fail fast tests
  # ?product_line_name=XX&manufacturer_name=XX&target_name=XX&target_category_name=XX&grouped_year=XX
  def missing_params?
    params[:product_line_name].blank? ||
      (params[:manufacturer_name].blank? && params[:target_name].present?) ||
      # target name and target category is mutually exclusive
      (params[:target_name].present? && params[:target_category_name].present?) ||
      # at least target has to be specified
      (params[:target_name].blank? && params[:target_category_name].blank?) ||
      # invalid qualifying year format
      (params[:target_name].present? && params[:grouped_year].present? && !TargetKit::qualifying_year_valid?(params[:grouped_year]))
  end
end
