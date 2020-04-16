class OrderKitsController < ApiController
  before_action :load_kit, except: :create

  def create
    order_kit, msg = BuildOrderKit.call(params).create
    render_error(msg) and return if msg.present?

    prompted_feature_values = order_kit.prompted_features.inject({}) do |memo, feature|
      memo[feature.name.symbolize] = params[feature.name.symbolize]
      memo
    end

    order_kit.apply_customer_prompted_feature_values prompted_feature_values

    render(:json => order_kit.as_hash, :status => :created)
  end

  def show
    render :json => @kit.as_hash
  end

  def update
    true
  end

  private

  def load_kit
    @kit = OrderKitHash.new(OrderKit.where(:id => params[:id]).take!)
  end
end
