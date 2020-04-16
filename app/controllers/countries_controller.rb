class CountriesController < ApiController
  def index
    collection = Country.only_base_columns
                        .includes(:interview_icon)
                        .has_an_interview_icon

    countries = ListCountries.call(
      collection: collection,
       address_formatter: nil,
       decorated_class: CountryWithoutAddress)

    render json: ({ countries: countries,
                   currencies: Currency.with_merchant_codes })
  end

  def show
    render json: Country.only_base_columns.find(params[:id])
  end

  class CountryWithoutAddress < SimpleDelegator
    def as_json(options = {})
      default_options = { methods: [:image_url], except: [:address_format] }
      super( default_options.reverse_merge(options) )
    end
  end

end
