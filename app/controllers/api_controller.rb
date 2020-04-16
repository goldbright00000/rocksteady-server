class ApiController < ApplicationController
  include ApplicationHelper

  before_action :convert_parameters

  def set_cache_header
    expires_in 5.minutes, :public=>true
  end

  def render_error(msg)
    render(:json => { error: msg }, status: :unprocessable_entity)
  end

  def convert_parameters
    names_to_ids(params)
  rescue StandardError => e
    logger.debug 'There were errors during parameter conversion'
    logger.debug 'Backtrace:'
    logger.debug "#{e.message}\n"
    # logger.debug e.backtrace.join "\n"

    head :not_found
  end
end
