class DesignerAddedTextFeature < TextFeature
  def build_properties
    super
    @empty_feature = true unless text.present?
  end

  def designer_added?
    true
  end
end

