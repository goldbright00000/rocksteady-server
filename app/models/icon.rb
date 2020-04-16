# Defines an icon and it's related svg or base64 data
class Icon < ActiveRecord::Base
  belongs_to :feature
  has_and_belongs_to_many :icon_tags
  has_many :countries, through: :country_icons
  has_many :country_icons
  has_many :feature_placements
  has_many :regulation_icons
  has_many :rule_set_icons
  has_many :rule_sets, through: :rule_set_icons
  has_many :target_icons
  has_many :targets, through: :target_icons

  # TODO: BM: MOT-2223 | This is just a temporary fix as we're not sure of what value to put here
  def self.default
    find_by(feature: Feature.find_by(name: "Corporate Logo") ).try(:id)
  end

  def bitmap?
    ['png', 'jpg', 'jpeg'].include?(data_format)
  end

  scope :tagged_with, (lambda do |tags|
    joins(:icon_tags).
    where(icon_tags: { name: tags }).
    group('`icons`.`id`').
    having('COUNT(`icons`.`id`) = ?', tags.size).
    # Without a given order, mysql uses the filesort algorithm which is performance killer. See: MOT-80
    order('NULL')
  end)

  def graphic_data
    data
  end

  def tags
    icon_tags
  end

end
