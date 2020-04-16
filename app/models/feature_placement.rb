class FeaturePlacement < ActiveRecord::Base

  belongs_to :b1f, foreign_key: 'b1f_id', class_name: 'Colour'
  belongs_to :b2f, foreign_key: 'b2f_id', class_name: 'Colour'
  belongs_to :b3f, foreign_key: 'b3f_id', class_name: 'Colour'
  belongs_to :b4f, foreign_key: 'b4f_id', class_name: 'Colour'
  belongs_to :colour, foreign_key: 'fill_id'
  belongs_to :feature
  belongs_to :font, foreign_key: 'font_family_id'
  belongs_to :icon
  belongs_to :position
  belongs_to :product_line
  belongs_to :regulation
  belongs_to :shape
  belongs_to :target_category
  belongs_to :target_kit

  #
  # Top & Left are misnamed in the current setup - pretend we know what the caller means
  #
  def top
    y
  end

  def left
    x
  end

  def alignment=(value)
    value = value.downcase if value.present?
    write_attribute :alignment, value
  end

  # */*/*
  # @return [Boolean]
  def is_rule_all?
    target_category_id.blank? && target_kit_id.blank? && position_id.blank? && shape_id.blank?
  end

  # */P/*
  # @return [Boolean]
  def is_rule_p?
    target_category_id.blank? && target_kit_id.blank? && position_id.present? && shape_id.blank?
  end

  # */*/S
  # @return [Boolean]
  def is_rule_s?
    target_category_id.blank? && target_kit_id.blank? && position_id.blank? && shape_id.present?
  end

  # */P/S
  # @return [Boolean]
  def is_rule_p_s?
    target_category_id.blank? && target_kit_id.blank? && position_id.present? && shape_id.present?
  end

  # TC/*/*
  # @return [Boolean]
  def is_rule_tc?
    target_category_id.present? && target_kit_id.blank? && position_id.blank? && shape_id.blank?
  end

  # TC/*/P
  # @return [Boolean]
  def is_rule_tc_p?
    target_category_id.present? && target_kit_id.blank? && position_id.present? && shape_id.blank?
  end

  # TC/*/S
  # @return [Boolean]
  def is_rule_tc_s?
    target_category_id.present? && target_kit_id.blank? && position_id.blank? && shape_id.present?
  end

  # TC/P/S
  # @return [Boolean]
  def is_rule_tc_p_s?
    target_category_id.present? && target_kit_id.blank? && position_id.present? && shape_id.present?
  end

  # TK/*/*
  # @return [Boolean]
  def is_rule_tk?
    target_category_id.blank? && target_kit_id.present? && position_id.blank? && shape_id.blank?
  end

  # TK/P/*
  # @return [Boolean]
  def is_rule_tk_p?
    target_category_id.blank? && target_kit_id.present? && position_id.present? && shape_id.blank?
  end

  # TK/*/S
  # @return [Boolean]
  def is_rule_tk_s?
    target_category_id.blank? && target_kit_id.present? && position_id.blank? && shape_id.present?
  end

  # TK/P/S
  # @return [Boolean]
  def is_rule_tk_p_s?
    target_category_id.blank? && target_kit_id.present? && position_id.present? && shape_id.present?
  end

end
