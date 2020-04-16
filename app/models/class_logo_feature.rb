class ClassLogoFeature < IconFeature
  def designer_icon_ids
    regulation.try(:icon_ids) || []
  end
end
