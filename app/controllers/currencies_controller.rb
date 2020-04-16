class CurrenciesController < ApiController
  CURRRENCY_SELECT = [:id, :name, :iso_code, :iso_numeric, :symbol, :fx_rate]

  def index
    currencies = Currency.all(:select => CURRRENCY_SELECT)
    render json: ({ 'currencies' => currencies })
  end

  def show
    render json: Currency.find(params[:id], :select => CURRRENCY_SELECT), :root => 'currency'
  end
end
