class Target < ActiveRecord::Base

  belongs_to :font_palette
  belongs_to :manufacturer
  belongs_to :target_category
  belongs_to :target_type
  has_many :characteristics, through: :target_characteristics
  has_many :icons, through: :target_icons
  has_many :kit_components, through: :kits
  has_many :kits, through: :target_kits
  has_many :target_characteristics
  has_many :target_icons
  has_many :target_kits

  #default_scope { order('targets.name ASC') }


  def available_regulations(rule_set_id, use_category_id = nil)
    sql = "SELECT DISTINCT r.id, tc.characteristic_id
             FROM regulation_constraints rc
             JOIN regulations r ON r.id = rc.regulation_id
             JOIN constraints c ON c.id = rc.constraint_id
             JOIN target_characteristics tc ON tc.characteristic_id = c.characteristic_id
            WHERE r.rule_set_id = #{rule_set_id}
              AND r.target_category_id = #{target_category_id}
              AND tc.target_id = #{id}"

    if use_category_id
      sql += " AND r.use_category_id = #{use_category_id}"
      possible_ids = Regulation.where(rule_set_id: rule_set_id, target_category_id: target_category_id, use_category_id: use_category_id).pluck(:id)
    else
      possible_ids = Regulation.where(rule_set_id: rule_set_id, target_category_id: target_category_id).pluck(:id)
    end

    exclude = sql + " AND ( ((c.lower_limit IS NULL) AND (tc.value <> c.exact_value))
                     OR ((c.exact_value IS NULL) AND ((tc.value < c.lower_limit) OR (tc.value > c.upper_limit))))"
    excluded = Target.connection.select_all(exclude)
    include = sql + " AND ( ((c.lower_limit IS NULL) AND (tc.value = c.exact_value))
                 OR ((c.exact_value IS NULL) AND (tc.value BETWEEN c.lower_limit AND c.upper_limit)) )"
    included = Target.connection.select_all(include)

    keep_excluded = excluded.inject([]) do |result, element|
      keep = included.select { |i| i['id'].eql?(element['id']) && i['characteristic_id'].eql?(element['characteristic_id']) }
      result << keep[0]['id'] if keep.present?
      result
    end

    excluded_ids = excluded.map { |e| e['id'] } - keep_excluded

    Regulation.where(id: possible_ids - excluded_ids)
  end


  def available_use_category_ids(rule_set)
    available_regulations(rule_set.id).pluck(:use_category_id).uniq
  end

  def acceptable_use_ids(rule_set_id, use_category_id)
    use_ids = available_regulations(rule_set_id, use_category_id).pluck(:use_id)
    Use.where(id: use_ids).map { |u| u.self_and_ancestors.pluck(:id) }.flatten.uniq
  end

  def to_s
    s = "#{manufacturer.name} #{name}"
    target_characteristics.order(:characteristic_id, :value).each do |tc|
      s += ",#{tc.characteristic.name}: #{tc.value}"
    end
    s
  end
end
