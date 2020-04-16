# A TargetCategory is an internal Rocksteady categorisation of Targets.
# It is there to allow us connect particular categories of Target to related
# UseCategories and other TargetCategory data that we're interested in.
class TargetCategory < ActiveRecord::Base

  belongs_to :colour_palette
  belongs_to :font_palette
  belongs_to :target_type

  delegate :colour_ids, to: :colour_palette
  delegate :font_ids, to: :font_palette

  has_many :interview_icon_target_categories
  has_many :interview_icons, :through => :interview_icon_target_categories
  has_many :kit_components, through: :targets
  has_many :kit_types, through: :target_category_positions
  has_many :positions, through: :target_category_positions
  has_many :regulations
  has_many :subkit_types
  has_many :target_category_positions
  has_many :target_category_shapes, through: :target_category_positions
  has_many :target_kits,  through: :targets
  has_many :targets
  has_many :use_categories, through: :regulations
  has_one :display_map_template

  attr_accessor :attached_product_line_id

  def display_map
    display_map_template.default_map
  end

  def available_use_category_ids(rule_set)
    regulations.where('rule_set_id = ?', rule_set.id).pluck(:use_category_id).uniq
  end

  def acceptable_use_ids(rule_set_id, use_category_id)
    use_ids = regulations.where(rule_set_id: rule_set_id, use_category_id: use_category_id).pluck(:use_id)
    Use.where(id: use_ids).map { |u| u.self_and_ancestors.pluck(:id) }.flatten.uniq
  end

  def image_url
    image
  end

  def image
    icon = interview_icons.where('interview_icon_target_categories.product_line_id = ?', @attached_product_line_id).first
    icon.present? ? icon.data : ''
  end

end
