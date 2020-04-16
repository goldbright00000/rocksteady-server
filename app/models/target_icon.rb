# Links Icons to Targets
class TargetIcon < ActiveRecord::Base

  default_scope { order('target_kit_id DESC, target_id DESC, manufacturer_id DESC, target_category_id DESC, target_type_id DESC, icon_id ASC') }

  belongs_to :icon
  validates :icon,
            presence: true

  belongs_to :target_type
  belongs_to :target_category
  belongs_to :manufacturer
  belongs_to :target
  belongs_to :target_kit

  # validate that one of the linking values is provided

  scope :for_target, lambda { |target_id| where(target_kit_id: nil, target_id: target_id) }
  scope :for_manufacturer, lambda { |manufacturer_id| for_target(nil).where(manufacturer_id: manufacturer_id) }
  scope :for_category, lambda { |target_category_id| where(target_category_id: target_category_id) }


  # There is ALWAYS a target_type_id (ProductLine selected determines it's value)
  # There is ALWAYS a target_category_id (Minimum requirement for a Kit)
  # The rest may or may not be populated
  # Hierarchy of Icons get less specific to the TargetKit as we go up the chain
  # TargetKit
  #   Target
  #     Manufacturer + TargetCategory
  #       Manufacturer + TargetType
  #         Manufacturer
  #           TargetCategory
  #             TargetType
  #
  # We group the levels of the hierarchy in 4 subsets:
  # A   target_kit
  #     target
  #     manufacturer & category
  # B   manufacturer & type
  #     manufacturer
  # C   category
  # D   type
  def self.icon_set(target_kit_id, target_id = nil, manufacturer_id = nil, target_category_id = nil, target_type_id = nil)
    icon_ids = []
    icon_ids << where(target_kit_id: target_kit_id).uniq.pluck(:icon_id) if target_kit_id
    icon_ids << for_target(target_id).uniq.pluck(:icon_id) if target_id
    icon_ids << for_manufacturer(manufacturer_id).where(target_category_id: target_category_id).uniq.pluck(:icon_id) if manufacturer_id

    if manufacturer_id && !icon_ids.flatten.present?
      icon_ids = for_manufacturer(manufacturer_id).where(target_category_id: nil, target_type_id: target_type_id).uniq.pluck(:icon_id)
      icon_ids << for_manufacturer(manufacturer_id).where(target_category_id: nil, target_type_id: nil).uniq.pluck(:icon_id)
    end

    if target_category_id && !icon_ids.flatten.present?
      icon_ids = for_category(target_category_id).where(target_type_id: target_type_id).uniq.pluck(:icon_id)
    end

    unless icon_ids.flatten.present?
      icon_ids = for_category(nil).where(target_type_id: target_type_id).uniq.pluck(:icon_id)
    end

    icon_ids.flatten.uniq
  end
end
