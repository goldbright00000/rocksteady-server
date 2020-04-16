class UserFlagFeature < IconFeature
  delegate :nationality, to: :order_kit_position

  belongs_to :country

  def nationality=(object)
    @country = object
  end

  def nationality
    @country || Country.default
  end

  #
  #   The nationality is used to pick the country flag
  #
  def value=(nationality_id)
    @country = Country.find(nationality_id)
  end

  def value
    return @country.id unless @country.nil?
    (value_overridden_by_regulation? ? regulation_feature.text : feature.sample_value).to_i
  end

  def designer_icon_ids
    nationality.icon_ids
  end

  private

  def value_overridden_by_regulation?
    regulation_feature.present? && regulation_feature.text.present?
  end
end
