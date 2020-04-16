class OrderKitHash < SimpleDelegator
  #
  #   Build a hash which can be turned into a JSON document
  #
  def as_hash
    self.all_colours = Colour.all
    build_designer_colour_ids
    positions, features, properties = positions_hashes

    kit        = {
        id:                  id,
        description:         description,
        width:               display_map.width.to_f,
        height:              display_map.height.to_f,

        # Interview Data
        product_line_id:     product_line.id,
        manufacturer_id:     manufacturer_id,
        target_id:           target_id,
        target_kit_id:       target_kit_id,
        target_category_id:  target_category_id,

        # Other
        is_target_category:  target_category?,
        competing_region_id: competing_region_id
    }

    # TODO: The nationality isn't a general comcept, so it needs to change.
    kit[:nationality_id] = user_flag.nationality.id if user_flag

    kit[:uses] = use.present? ? use.full_name_as_array : []

    manufacturer_ids = self.kit_components.map { |c| c[:manufacturer_id] }.uniq

    if manufacturer && !manufacturer_ids.include?(manufacturer.id)
      manufacturer_ids << manufacturer.id
    end

    manufacturers = Manufacturer.where(id: manufacturer_ids)

    kit[:font_ids]    = Font.select('id').map { |f| f.id }
    kit[:graphic_ids] = all_graphic_ids

    kit[:position_ids]  = positions.map { |p| p[:id] }
    kit[:component_ids] = self.kit_components.map { |p| p[:id] }
    kit[:feature_ids]   = features.map { |p| p[:link] }
    kit[:attribute_ids] = properties.map { |p| p[:link] }

    decals          = Decal.where(id: self.kit_components.collect { |c| c[:decal_ids] }.flatten.uniq)
    kit[:decal_ids] = decals.map { |p| p[:id] }

    fonts = Font.where(id: font_ids)

    graphics = kit_graphics(properties)

    kit[:graphic_ids] = graphics.map { |e| e.id }

    targets           = Target.where(id: target_id)
    target_kits       = TargetKit.where(id: target_kit_id)
    target_categories = TargetCategory.where(id: target_category_id)



    kit[:prompted_features] = prompted_features.map do |f|
      feature = f.feature
      { id: feature.id, name: feature.name, value: f.value}
    end


    order_kit = {
        :order_kit         => kit,
        :attributes        => properties,
        :features          => features,
        :components        => self.kit_components,
        :positions         => positions,
        :shapes            => self.kit_shapes,
        :decals            => ActiveModel::Serializer::CollectionSerializer.new(decals.compact, scope: { scope: true }),
        :fonts             => ActiveModel::Serializer::CollectionSerializer.new(fonts.compact, scope: { scope: true }),
        :graphics          => ActiveModel::Serializer::CollectionSerializer.new(graphics, scope: { scope: true }),
        :manufacturers      => ActiveModel::Serializer::CollectionSerializer.new(manufacturers, scope: { scope: true }),
        :targets           => ActiveModel::Serializer::CollectionSerializer.new(targets, scope: { scope: true }),
        :target_kits       => ActiveModel::Serializer::CollectionSerializer.new(target_kits, scope: { scope: true }),
        :target_categories => ActiveModel::Serializer::CollectionSerializer.new(target_categories, scope: { scope: true }),
    }

    if regulated?
      kit.merge!(
          {
              :rule_set_id     => rule_set_id,
              :use_category_id => use_category_id,
              :use_id          => use_id,
              :regulation_id   => regulation_id
          })

      order_kit.merge!(
          {
              use_categories: [
                                  {
                                      id:   use_category_id,
                                      name: use_category.name
                                  }
                              ],
              rule_sets:      [
                                  {
                                      id:   rule_set_id,
                                      name: rule_set.name
                                  }
                              ]
          }
      )
    end



    order_kit
  end

  private

  #
  #   Call '.name' on the elements of the array,
  #   returning the string as a description for
  #   the kit
  #
  def mk_description(*array)
    array.reduce('') do |sum, e|
      sum = e ? "#{sum} #{e.name}" : sum
    end.strip
  end

  def description
    if target_kit.present?
      descriptive = target_kit # Part of the description
    else
      descriptive = target_category # Part of the description
    end

    use_names = []
    parent    = use
    until parent.nil?
      use_names.append(parent.name)
      parent = parent.parent
    end
    use_names.reverse!

    # annon class for compatability with mk_description()
    full_use_name_class = Class.new do
      attr_accessor :name
    end
    full_use            = full_use_name_class.new()
    full_use.name       = use_names.join(' ')

    mk_description(manufacturer, target, descriptive, rule_set, use_category, full_use)
  end

  #
  #   Return the actual data for the graphics - not just the ids.
  #   We need to do this because the Kit cannot render until the
  #   Selector has all the data it needs.
  #
  def kit_graphics(properties)
    ids = properties.select { |p| p[:name].eql?('Icon') }.map { |p| p[:designer] }.flatten.uniq
    Icon.where(id: ids)
  end

  #
  #   Return a lists of the ids. The UI can side load these
  #
  def all_graphic_ids
    Icon.select('id').map { |i| i.id }
  end


  def positions_hashes
    self.kit_components = {}
    self.kit_shapes     = {}
    self.list_of_regulated_colours    = []
    self.list_of_unregulated_features = []

    positions       = {}
    features        = Set.new []
    properties      = Set.new []

    # For now we're only loading the positioning for the default shape on the default component
    # an additional call to the server will be required to get the placements for alternatives
    order_kit_positions.includes(display_map_position: {}, target_category_position: :position).each do |order_kit_position|
      position, position_features, position_properties = order_kit_position.as_hash

      positions[order_kit_position.position_id] = position
      features << position_features
      properties << position_properties
    end

    properties = properties.to_a.flatten

    # post processing designer colours for regulated kits
    if regulated? && self.list_of_regulated_colours.present?
      self.list_of_regulated_colours.flatten!.uniq!

      properties.each { |p|
        next unless list_of_unregulated_features.include? p[:link]

        p[:designer] << self.list_of_regulated_colours
        p[:designer].flatten!.uniq!.sort!
      }
    end

    self.kit_components = self.kit_components.values
    self.kit_shapes     = self.kit_shapes.values
    return positions.values, features.to_a.flatten, properties
  end
end
