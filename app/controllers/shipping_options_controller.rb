class ShippingOptionsController < ApiController

  def index
    return head :unprocessable_entity unless valid_params?(params)

    render json: {
        shipping_options: ShippingOption::get_options(params)
    }

  end

  protected

  def valid_params?(params)
    params[:iso2_country_code].present? &&
        params[:price].present? &&
        params[:discount_code_type].present? &&
        [
            Rocksteady::DISCOUNT_TYPE_NONE,
            Rocksteady::DISCOUNT_TYPE_PROMOTION,
            Rocksteady::DISCOUNT_TYPE_CHANGE_DESIGN,
            Rocksteady::DISCOUNT_TYPE_ORDER_FIX
        ].include?(params[:discount_code_type])
  end
end
