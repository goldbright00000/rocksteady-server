# ProductLine is the nexus of the data, where Targets, Kits and Regulations are
# all brought together.
class ProductLine < ActiveRecord::Base

  belongs_to :kit_type
  belongs_to :target_type
  has_many :display_map_templates
  has_many :feature_placements
  has_many :regulation_placements
  has_many :rule_sets
  has_many :shapes
  has_one :interview_icon

  has_many :kits, -> { distinct }, through: :kit_type
  has_many :target_kits, through: :kits
  has_many :targets, (lambda do |product_line|
    distinct.where(target_type_id: product_line.target_type_id)
  end), through: :target_kits
  has_many :manufacturers, -> { distinct }, through: :targets
  has_many :target_categories, :through => :target_type
  has_many :use_categories, :through => :target_categories

  has_and_belongs_to_many :features

  scope :find_by_name, (lambda do |name|
    *target_type, kit_type = name.split(' ')

    joins(:kit_type, :target_type)
    .where(target_types: { name: target_type.join(' ')},
           kit_types:  { name: kit_type }).take!
  end)

  # TODO VV: if the name is not changing so often,
  # then it should not be dynamically built but put down to the model as a property in db
  def name
    "#{target_type.name} #{kit_type.name}"
  end

  def regulated
    !!read_attribute(:regulated).nonzero?
  end
  alias_method :is_regulated, :regulated

  def image
    interview_icon.present? ? interview_icon.data : ''
  end
  alias_method :image_url, :image

  def applicable_rule_sets(country, target_category)
    rule_set_ids = country.available_rule_set_ids
    if target_category
      rule_set_ids = rule_set_ids & target_category.regulations.map(&:rule_set_id)
    end
    rule_sets.includes(:product_line).where(id: rule_set_ids)
  end
end
