class BuildOrderKit
  # ProductLine, (TargetKit | Target | (Manufacturer & TargetCategory) | TargetCategory), [Nationality], [RuleSet], [UseCategory], [Use], prompted_features
  def self.call(params)
    new.call(params)
  end

  class InvalidOrder
    def initialize(msg:)
      @msg = msg
    end
    def create
      return [nil, @msg]
    end
    def delete_kit;end
  end

  attr_reader :params, :order, :order_kit

  #
  #   This is the entry point for building the kit. The params come straight from
  #   the interview via the order kit controller
  #
  def call(params)
    return InvalidOrder.new(msg: 'You must provide a product_line_id') unless params[:product_line_id]
    product_line = ProductLine.find(params[:product_line_id])

    order = Order.new
    order_kit = OrderKit.new(order: order)

    #
    # Verify the selections by finding them on the database
    # Raises 404 if the product_line is not valid
    #
    order_kit.product_line = product_line

    #
    #   The order_kit is sensitive to the path through the interview
    #
    target_kit_interview(order_kit, params) or
        target_interview(order_kit, params) or
        manufacturer_interview(order_kit, params) or
        target_category_interview(order_kit, params) or
        return InvalidOrder.new(msg: 'An invalid interview path was provided')

    if params[:use_id]
      order_kit.use          = Use.find(params[:use_id])
      order_kit.use_category = UseCategory.find(params[:use_category_id]) if params[:use_category_id]
      order_kit.rule_set     = RuleSet.find(params[:rule_set_id]) if params[:rule_set_id]

      # There may be more than one Regulation matching the RuleSet/UseCategory/Use breakdown
      # we only want the one that's applicable to the selected target
      regulation = if order_kit.target
        order_kit.target.available_regulations(params[:rule_set_id],
                                               params[:use_category_id])
                        .where(use_id: params[:use_id])
      else
        regulation = Regulation.where(rule_set_id:        order_kit.rule_set_id,
                                                use_category_id:    order_kit.use_category_id,
                                                target_category_id: order_kit.target_category_id,
                                                use_id:             order_kit.use_id)
      end

      order_kit.regulation = regulation.includes(:icons, series_sponsor: [:icons]).first



    elsif params[:use_category_id]
      order_kit.use_category = UseCategory.find(params[:use_category_id])
      order_kit.rule_set     = RuleSet.find(params[:rule_set_id]) if params[:rule_set_id]

    elsif params[:rule_set_id]
      order_kit.rule_set = RuleSet.find(params[:rule_set_id])
    end

    @order = order
    @order_kit = order_kit
    @order_kit.customer_geo_location = Country.find_by(iso_code2: params[:geo_location]) || Country.default

    @params = params

    return self
  end


  def create(position_and_features_builder: BuildOrderPositionAndFeatures, serializer: OrderKitHash )
    if @order.valid? && @order_kit.valid?
      # In time the client should return [:prompted_features][<feature name>]
      @order_kit.order_kit_positions = position_and_features_builder.(order_kit)

      # augment 'order_kit' object, passing on values from params
      @order_kit.competing_region_id = @params[:competing_region_id]

      @order_kit = serializer.new(@order_kit)

      result = [@order_kit, nil]
    else
      result = [@order_kit, @order.errors]
    end

    result
  end

  private
  def target_kit_interview(order_kit, params)
    return false if params[:target_kit_id].blank?

    order_kit.target_kit      = TargetKit.find(params[:target_kit_id])
    order_kit.target          = order_kit.target_kit.target
    order_kit.manufacturer    = order_kit.target.manufacturer
    order_kit.target_category = order_kit.target.target_category

    true
  end

  def target_interview(order_kit, params)
    return false if params[:target_id].blank?
    order_kit.target          = Target.find(params[:target_id])
    order_kit.manufacturer    = order_kit.target.manufacturer
    order_kit.target_category = order_kit.target.target_category

    true
  end

  def manufacturer_interview(order_kit, params)
    return false if params[:manufacturer_id].blank?
    order_kit.manufacturer    = Manufacturer.find(params[:manufacturer_id])
    order_kit.target_category = TargetCategory.find(params[:target_category_id])

    true
  end

  def target_category_interview(order_kit, params)
    return false if params[:target_category_id].blank?
    order_kit.target_category = TargetCategory.find(params[:target_category_id])

    true
  end

end
