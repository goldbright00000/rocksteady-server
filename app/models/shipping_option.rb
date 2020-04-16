class ShippingOption < ActiveRecord::Base
  belongs_to :postal_option
  belongs_to :shipping_option_type, foreign_key: 'type_id'

  # @param [Hash] params
  def self.get_options(params)
    query = self.where(iso_code2: params[:iso2_country_code]).eager_load(:shipping_option_type)

    if params[:price].to_f < Rocksteady::SHIPPING_MINIMAL_VALUE.to_f

      types = case params[:discount_code_type].downcase
                when Rocksteady::DISCOUNT_TYPE_NONE, Rocksteady::DISCOUNT_TYPE_PROMOTION
                  [ShippingOptionType::STANDARD, ShippingOptionType::EXPEDITED]
                when Rocksteady::DISCOUNT_TYPE_ORDER_FIX, Rocksteady::DISCOUNT_TYPE_CHANGE_DESIGN
                  [ShippingOptionType::FREE, ShippingOptionType::EXPEDITED]
              end

    else
      types = [ShippingOptionType::FREE, ShippingOptionType::EXPEDITED]
    end

    query = query.where('shipping_option_types.name IN (?)', types)

    query.map { |so| so.as_hash }
  end

  def as_hash
    {
        id:             id,
        type:           shipping_option_type.name,
        cost:           price.to_f,
        time:           delivery_time,
        phone_required: phone_required,
        postal_company: postal_option.company_name,
        postal_service: postal_option.service_name
    }
  end

end
