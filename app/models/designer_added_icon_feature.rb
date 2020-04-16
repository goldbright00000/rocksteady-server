class DesignerAddedIconFeature < IconFeature
  def designer_added?
    true
  end

  def designer_icon_ids
    if self.icon_id.nil?
      []
    else
      [ self.icon_id ]
    end
  end
end
