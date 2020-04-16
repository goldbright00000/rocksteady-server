# Defines 'qualifying data' when a target is in a given kit_specification
class TargetKit < ActiveRecord::Base

  belongs_to :colour_palette
  belongs_to :kit
  belongs_to :target

  delegate :kit_components, :display_map, to: :kit

  has_many :order_kits

  QUALIFYING_YEAR_MATCHER = /^(?:\d{4}(?:[,\-]\d{4})*)+$/

  # @return [Boolean]
  def self.qualifying_year_valid?(year)
    QUALIFYING_YEAR_MATCHER =~ year ? true : false
  end

  #
  #   Ok, not really a name but it make TK
  #   behave more like product_line, use, target ...
  #
  def name
    self.qualifying_data
  end

  def fullname
    "#{target.name} #{qualifying_data}"
  end

end
