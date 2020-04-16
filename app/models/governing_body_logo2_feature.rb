class GoverningBodyLogo2Feature < IconFeature

  def designer_icon_ids
    rule_set.try(:icon_ids) || []
  end

end
