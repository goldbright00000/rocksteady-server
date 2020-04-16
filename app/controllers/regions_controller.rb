class RegionsController < ApiController
  def index
    countries = ListCountries.call(
      collection: Country
                  .only_base_columns
                  .has_an_interview_icon
                  .includes(:interview_icon, :icons))

    render(json: { regions: countries,
                   currencies: Currency.with_merchant_codes })
  end

  def show
    render json: Country.only_base_columns.find(params[:id])
  end
end
