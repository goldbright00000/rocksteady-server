class SeriesSponsorFeature < IconFeature
  def designer_icon_ids
    if regulation && regulation.series_sponsor
      regulation.series_sponsor.icon_ids
    end || []
  end
end
