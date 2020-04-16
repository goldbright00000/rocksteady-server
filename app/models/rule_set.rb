# Defines RuleSets and links them with a specific product_line.
class RuleSet < ActiveRecord::Base

  belongs_to :product_line
  belongs_to :regulatory_body, class_name: 'RuleSet'
  has_many :interview_icon_rule_sets
  has_many :regulations
  has_many :rule_set_icons
  has_many :use_categories, through: :regulations

  has_many :icons, through: :rule_set_icons
  has_many :interview_icons, :through => :interview_icon_rule_sets
  has_many :regulation_colour_palettes, through: :regulation_feature_properties
  has_many :regulation_colour_palette_colours, through: :regulation_colour_palettes
  has_many :regulation_features, through: :regulations
  has_many :regulation_feature_properties, through: :regulation_features

  default_scope { order(:name) }

  attr_accessor :attached_product_line_id

  def self_regulated?
    regulatory_body_id.eql?(id)
  end

  def regulatory_body_icon_ids
    if self_regulated?
      []
    else
      regulatory_body.icon_ids
    end
  end

  def colour_ids
    regulation_colour_palette_colours.where(exclude: false).pluck(:colour_id).uniq
  end

  def image_url
    image
  end

  def image
    icon = interview_icons.where('interview_icon_rule_sets.product_line_id = ?', @attached_product_line_id).first
    icon.present? ? icon.data : ''
  end

end
