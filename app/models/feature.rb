require_relative '../../lib/eav_fields'

# Features are predefined Text, Shape and Graphic items that are Placed on a
# Shape to make a printable item.
class Feature < ActiveRecord::Base

  eav_fields value: :editable

  belongs_to :feature_type
  has_many :regulation_features

  has_and_belongs_to_many :product_lines
  has_many :icons

  scope :available_on_product_line, ->(product_line) { joins(:product_lines).where('product_lines.id = ?', product_line.id) }

  def proscribed?
    presence_regulated == 2
  end

  def self.regulatory_body
    find_by(name: 'Regulatory Body Logo')
  end

  def self.background
    find_by(name: 'Background')
  end

  def type
    feature_type.name
  end

  def text?
    feature_type.name.eql?('Text')
  end

  def icon?
    feature_type.name.eql?('Icon')
  end

  def shape?
    feature_type.name.eql?('Shape')
  end

  def user_number?
    name.eql?('User Number')
  end

  def corporate_logo?
    name.eql?('Corporate Logo')
  end

  def background?
    name.eql?('Background')
  end

  # FIXME: HACK to convert to types expected on the client
  def client_type
    { 'Shape' => 'ComponentShape',  'Icon' => 'GraphicIcon' }
      .fetch(feature_type.name, feature_type.name)
  end
end
