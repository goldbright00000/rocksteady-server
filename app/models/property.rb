class Property < ActiveRecord::Base

  # Z Index is currently returned as part of the Feature rather than as an attribute
  PLACEMENTS   = %w(Top Left Angle Scale) #, 'Z Index']

  TEXT_PROPERTIES = ['Text', 'Font Family', 'Font Size', 'Line Height', 'Letter Spacing', 'Text Alignment']
  BACKGROUND_PROPERTIES = ['Stroke Internal 1', 'Stroke Front 1' ]

  has_many :feature_type_properties
  has_many :feature_properties

  @@properties = all.inject({}) { |hash, p| hash[p.name] = p; hash } unless class_variable_defined?(:@@properties)

  def self.[](name)
    @@properties[name]
  end

  def self.properties
    @@properties
  end

  def self.placement_properties
    @@properties.map { |k, v| PLACEMENTS.include?(k) ? v : nil }.compact
  end

  def self.text_properties
    @@properties.map { |k, v| TEXT_PROPERTIES.include?(k) ? v : nil }.compact
  end

  def self.background_properties
    @@properties.map { |k, v| BACKGROUND_PROPERTIES.include?(k) ? v : nil }.compact
  end

  def self.stroke_width_properties
    @@properties.map { |k, v| k.start_with?('Stroke Width') ? v : nil }.compact
  end

  def self.stroke_style_properties
    @@properties.map { |k, v| k.start_with?('Stroke Style') ? v : nil }.compact
  end

  def field_name
    name.parameterize.underscore
  end

  def text?
    name.eql?('Text')
  end

  def font_family?
    name.eql?('Font Family')
  end

  def stroke_level
    if name.start_with?('Stroke')
      name[-1].to_i
    else
      nil
    end
  end

  #
  # Only Required for TestOrder
  #
  def source_association
    if source
      source.constantize
    else
      nil
    end
  end

  def self.top
    @@properties['Top']
  end

  def self.left
    @@properties['Left']
  end

end
