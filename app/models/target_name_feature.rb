class TargetNameFeature < TextFeature
  def text_value
    if text.present?
      value = text
    else
      if order_kit.target.present?
        value = order_kit.target.name
      else
        value = feature.sample_value
      end
    end
    { value: value }
  end
end
