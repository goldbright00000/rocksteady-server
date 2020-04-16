class RegulatoryBodyLogoFeature < IconFeature
  def designer_icon_ids
    rule_set.try(:regulatory_body_icon_ids) || []
  end
end
