# A Regulation connects a UseCategory, a Use, and a RuleSet.
class Regulation < ActiveRecord::Base

  belongs_to :font_palette
  belongs_to :rule_set
  belongs_to :series_sponsor
  belongs_to :target_category
  belongs_to :use
  belongs_to :use_category
  has_many :regulation_constraints
  has_many :regulation_features
  has_many :regulation_finishes
  has_many :regulation_icons

  has_many :themes

  has_many :regulation_colour_palette_colours, through: :regulation_colour_palettes
  has_many :regulation_feature_properties, through: :regulation_features
  has_many :regulation_colour_palettes, through: :regulation_feature_properties
  has_many :icons, through: :regulation_icons
  has_many :constraints, through: :regulation_constraints

  def self.find_by_names(rule_set_name, use_category_name, use_name)
    where(
        rule_set_id: RuleSet.where(name: rule_set_name).take!.id,
        use_category_id: UseCategory.where(name: use_category_name).take!.id,
        use_id: Use.where(name: use_name).pluck(:id)
    )
  end

  def name(separator:'/')
    [rule_set.name, use_category.name, use.full_name(separator: separator)].join(separator)
  end

  def colour_ids
    if @colour_ids.blank?
      colour_ids = []
      fill_colours = regulation_feature_properties.where(property_id: Property['Fill'].id).pluck(:value)

      RegulationColourPalette.where(id: fill_colours).each do |palette|
        colour_ids << palette.regulation_colour_palette_colours.where(exclude: false).pluck(:colour_id)
      end

      @colour_ids = colour_ids.flatten.uniq
    end

    @colour_ids
  end

  def font_ids
    if @font_ids.blank?
      palette = FontPalette.where(
          id: regulation_feature_properties.where(property_id: Property['Font Family'].id).pluck(:value)
      ).take
      if palette
        @font_ids = palette.font_palette_fonts.pluck(:font_id)
      else
        @font_ids = []
      end
    end

    @font_ids
  end

  # Some features are pre-assigned a value in the regulations and must not be
  # changed by the user.
  def fixed_text_features
    if @fixed_text_features.blank?
      sql = "
           SELECT f.id AS feature_id, max(value), sum(editable) AS editable
             FROM features f
               LEFT OUTER JOIN regulation_features rf ON rf.feature_id = f.id AND rf.regulation_id = #{id}
               JOIN regulation_feature_properties rfp ON rfp.regulation_feature_id = rf.id
            WHERE f.visible_to_user
              AND f.prompt = 1
              AND rfp.property_id = #{Property['Text'].id}
              AND editable = 0
              AND (    ((f.presence_regulated = 0) AND (ifnull(rf.requirement, 0) > -1))
                    OR ((f.presence_regulated = 1) AND (ifnull(rf.requirement, 0) > -1))
                    OR ((f.presence_regulated = 2) AND (ifnull(rf.requirement, -1) > -1))
                  )
            GROUP BY feature_id
        "
      @fixed_text_features = Feature.connection.select_all(sql).inject({}) { |hash, f| hash[f['feature_id']] = f['value']; hash }
    end

    @fixed_text_features
  end

end
