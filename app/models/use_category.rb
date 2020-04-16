class UseCategory < ActiveRecord::Base

  has_many :regulation_colour_palette_colours, through: :regulation_colour_palettes
  has_many :regulation_colour_palettes, through: :regulation_feature_properties
  has_many :regulation_feature_properties, through: :regulation_features
  has_many :regulation_features, through: :regulations
  has_many :regulations
  has_many :target_categories, through: :regulations
  has_many :uses, through: :regulations

  attr_accessor :attached_product_line_id

  def colour_ids
    regulation_colour_palette_colours.where(exclude: false).pluck(:colour_id).uniq
  end

  def image_url
    self.data
  end
end
