class PlaceableFeature < OrderKitPositionFeature

  def build_properties
    super
    Property.placement_properties.each do |property|
      # TODO RM541 should this default rule have values? - CM
      #add_property(property, { value: self.send(property.field_name), rule: [] })
      add_property(property, { value: cast(self.send(property.field_name), property.field_name ), rule: [] })
    end
  end

  private

  def cast(value, property)
    return value if value.nil?
    return value if property == 'angle'
    value.to_f
  end

end
