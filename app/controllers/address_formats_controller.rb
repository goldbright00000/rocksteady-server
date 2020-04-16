class AddressFormatsController < ApiController
  def show
    @country = Country.only_base_columns.find(params[:country_id])
    render json: ({ address_format: Rst::AddressFormatter.new.call(@country)})
  end
end
