require 'rst/fam_removals'

class BuildOrderPositionAndFeatures
  attr_reader :order_kit

  def initialize(order_kit)
    @order_kit = order_kit
  end

  def self.call(order_kit)
    new(order_kit).create
  end

  def create
    positions = find_positions
    positions = apply_features(positions)
    positions
  end

  private

  def find_positions
    connection.execute(create_positions_sql).map do |pos|
      position = OrderKitPosition.new(order_kit: order_kit)

      position.target_category_position_id, position.shape_id, position.decal_id,
        position.kit_component_id, position.display_map_position_id, position.quantity,
        position.created_at, position.updated_at = pos

      position
    end
  end

  def apply_features(positions)
    features(positions).each do |feat|
      position_index = feat.last

      feature = OrderKitPositionFeature.instantiate_for_type(OpenStruct.new(id: feat[1], name: feat[3], type: feat[4]), order_kit_position: positions[position_index])

      positions[position_index].order_kit_position_features << feature

      feature.position_id, feature.feature_id, feature.regulation_feature_id, _, _,
        feature.x, feature.y, feature.angle, feature.scale, feature.z_index,
        feature.icon_id, feature.fill_colour_id, feature.text, feature.font_size, feature.font_id,
        feature.text_alignment, feature.letter_spacing, feature.line_height, feature.stroke_style_1,
        feature.stroke_style_2, feature.stroke_style_3, feature.stroke_style_4, feature.stroke_width_1,
        feature.stroke_width_2, feature.stroke_width_3, feature.stroke_width_4, feature.flip_x,
        feature.flip_y, feature.stroke_internal_1, feature.stroke_front_1, feature.created_at, feature.updated_at, _, _, _, _ = feat
    end unless positions.to_a.empty?

    apply_removals(positions)
  end

  def create_positions_sql
    target_kit? ? positions_for_target_kit : positions_for_target_category_kit
  end

  def features(positions)
    order_kit.regulated? ? create_features_for_regulated_kit(positions) : create_features_for_unregulated_kit(positions)
  end

  def create_features_for_unregulated_kit(positions)
    result = []
    result += connection.execute(create_target_kit_features_sql(positions)).to_a if order_kit.target_kit.present?
    result += connection.execute(create_target_category_features_sql(positions)).to_a
    result = result.uniq { |f| "#{f[0]}-#{f[1]}" }
  end

  def create_features_for_regulated_kit(positions)
    result = []
    result += connection.execute(create_regulated_target_kit_features_sql(positions)).to_a if order_kit.target_kit.present?
    result += connection.execute(create_regulated_target_category_features_sql(positions)).to_a

    # For Self-regulated RuleSets we only want to see the Governing Body Logo (Features Test #6)
    if order_kit.regulated? && order_kit.rule_set.self_regulated?
      result.each do |f|
        result.delete(f) if f[1] == Feature.regulatory_body.id
      end
    end

    result = result.uniq {|f| "#{f[0]}-#{f[1]}" }
  end

  def target_kit?
    order_kit.target_kit && order_kit.target_kit.kit_components.present?
  end

  def create_target_kit_features_sql(positions)
    <<-SQL
SELECT
  DISTINCT
  `tcp`.`position_id`,
  `f`.`id` AS `feature_id`,
  NULL AS `regulation_feature_id`,
  `f`.`name` AS `feature_name`,
  `ft`.`name` as `feature_type`,
  `fp`.`x`, `fp`.`y`,
  `fp`.`angle`, `fp`.`scale`, `fp`.`z_index`,
  `fp`.`icon_id`, `fp`.`fill_id` AS `fill_colour_id`,
  `fp`.`text`, `fp`.`font_size`, `fp`.`font_family_id`, `fp`.`alignment`, `fp`.`spacing`, `fp`.`height`,
  `fp`.`b1f_id`, `fp`.`b2f_id`, `fp`.`b3f_id`, `fp`.`b4f_id`, `fp`.`b1w`, `fp`.`b2w`, `fp`.`b3w`, `fp`.`b4w`, `fp`.`flip_x`, `fp`.`flip_y`, `fp`.`stroke_internal_1`, `fp`.`stroke_front_1`,
  CURRENT_TIMESTAMP AS `created_at`, CURRENT_TIMESTAMP AS `updated_at`, `fp`.`target_category_id`, `fp`.`position_id`, `fp`.`shape_id`,
  `okp`.`array_index`
FROM
  ( #{virtual_order_kit_position(positions)} ) `okp`
  JOIN `target_category_positions` `tcp` ON `tcp`.`id` = `okp`.`target_category_position_id`
  JOIN `shapes` `s` ON `s`.`id` = `okp`.`shape_id`
  JOIN `feature_placements` `fp` ON ( `fp`.`target_kit_id` = #{order_kit.target_kit_id}) AND ( `tcp`.`position_id` = `fp`.`position_id` OR `fp`.`position_id` IS NULL ) AND ( `fp`.`shape_id` = `s`.`id` OR `fp`.`shape_id` IS NULL )
  JOIN `features` `f` ON `f`.`id` = `fp`.`feature_id`
  JOIN `feature_types` `ft` ON `f`.`feature_type_id` = `ft`.`id`
WHERE
  `fp`.`product_line_id` = #{order_kit.product_line.id} AND `f`.`visible_to_user` = 1 AND `f`.`presence_regulated` = 0 AND `fp`.`target_category_id` IS NULL
ORDER BY
  `fp`.`target_category_id` DESC, `fp`.`position_id` DESC, `fp`.`shape_id` DESC
SQL
  end

  def create_target_category_features_sql(positions)
    <<-SQL
SELECT
  DISTINCT
  `tcp`.`position_id`,
  `f`.`id` AS `feature_id`,
  NULL AS `regulation_feature_id`,
  `f`.`name` AS `feature_name`,
  `ft`.`name` as `feature_type`,
  ROUND( IF( `fp`.`shape_id` IS NULL, `fp`.`x` * `s`.`editor_width`, `fp`.`x` ), 6 ) AS `x`,
  ROUND( IF( `fp`.`shape_id` IS NULL, `fp`.`y` * `s`.`editor_height`, `fp`.`y` ), 6 ) AS `y`,
  `fp`.`angle`, `fp`.`scale`, `fp`.`z_index`, `fp`.`icon_id`, `fp`.`fill_id` AS `fill_colour_id`,
  `fp`.`text`, `fp`.`font_size`, `fp`.`font_family_id`, `fp`.`alignment`, `fp`.`spacing`, `fp`.`height`,
  `fp`.`b1f_id`, `fp`.`b2f_id`, `fp`.`b3f_id`, `fp`.`b4f_id`, `fp`.`b1w`, `fp`.`b2w`, `fp`.`b3w`, `fp`.`b4w`, `fp`.`flip_x`, `fp`.`flip_y`, `fp`.`stroke_internal_1`, `fp`.`stroke_front_1`,
  CURRENT_TIMESTAMP AS `created_at`, CURRENT_TIMESTAMP AS `updated_at`,
  `fp`.`target_category_id`, `fp`.`position_id`, `fp`.`shape_id`,
  `okp`.`array_index`
FROM
    ( #{virtual_order_kit_position(positions)} ) `okp`
  JOIN `target_category_positions` `tcp` ON `tcp`.`id` = `okp`.`target_category_position_id`
  JOIN `target_categories` `tc` ON `tc`.`id` = `tcp`.`target_category_id`
  JOIN `shapes` `s` ON `s`.`id` = `okp`.`shape_id`
  JOIN `feature_placements` `fp` ON ( `fp`.`target_category_id` = `tc`.`id` OR `fp`.`target_category_id` IS NULL ) AND ( `tcp`.`position_id` = `fp`.`position_id` OR `fp`.`position_id` IS NULL ) AND ( `fp`.`shape_id` = `s`.`id` OR `fp`.`shape_id` IS NULL )
  JOIN `features` `f` ON `f`.`id` = `fp`.`feature_id`
  JOIN `feature_types` `ft` ON `f`.`feature_type_id` = `ft`.`id`
WHERE
      `fp`.`product_line_id` = #{order_kit.product_line.id} AND `f`.`visible_to_user` = 1 AND `f`.`presence_regulated` = 0 AND `fp`.`target_kit_id` IS NULL
ORDER BY
  `fp`.`target_category_id` DESC, `fp`.`position_id` DESC, `fp`.`shape_id` DESC
SQL
  end

  def create_regulated_target_kit_features_sql(positions)
    <<-SQL
SELECT
  `tcp`.`position_id`,
  `f`.`id` AS `feature_id`,
  `rf`.`id` AS `regulation_feature_id`,
  `f`.`name` AS `feature_name`,
  `ft`.`name` as `feature_type`,
  ROUND( IF(
            `rp`.`x` IS NOT NULL,
            `rp`.`x` * `s`.`editor_width`,
            IF( `fp`.`shape_id` IS NULL, `fp`.`x` * `s`.`editor_width`, `fp`.`x` )
            ), 6 ) AS `x`,
  ROUND( IF(
            `rp`.`y` IS NOT NULL,
            `rp`.`y` * `s`.`editor_height`,
            IF( `fp`.`shape_id` IS NULL, `fp`.`y` * `s`.`editor_height`, `fp`.`y` )
            ), 6 ) AS `y`,
  IFNULL( `rp`.`angle`, `fp`.`angle` ) AS `angle`,
  IFNULL( `rp`.`scale`, `fp`.`scale` ) AS `scale`,
  IFNULL( `rp`.`z_index`, `fp`.`z_index` ) AS `z_index`,
  IFNULL( `rp`.`icon_id`, `fp`.`icon_id` ) AS `icon_id`,
  IFNULL(
          IF ( `rp`.`fill_id` > 0, CONCAT('FAMREG', `rp`.`fill_id`), NULL ), # augment value marking it's origin
          `fp`.`fill_id`
        ) AS `fill_colour_id`,
  IFNULL( `rp`.`text`, `fp`.`text` ) AS `text`,
  IFNULL( `rp`.`font_size`, `fp`.`font_size` ) AS `font_size`,
  IFNULL( `rp`.`font_family_id`, `fp`.`font_family_id` ) AS `font_id`,
  IFNULL( `rp`.`alignment`, `fp`.`alignment` ) AS `text_alignment`,
  IFNULL( `rp`.`spacing`, `fp`.`spacing` ) AS `letter_spacing`,
  IFNULL( `rp`.`height`, `fp`.`height` ) AS `line_height`,
  IFNULL( `rp`.`b1f_id`, `fp`.`b1f_id` ) AS `stroke_style_1`,
  IFNULL( `rp`.`b2f_id`, `fp`.`b2f_id` ) AS `stroke_style_2`,
  IFNULL( `rp`.`b3f_id`, `fp`.`b3f_id` ) AS `stroke_style_3`,
  IFNULL( `rp`.`b4f_id`, `fp`.`b4f_id` ) AS `stroke_style_4`,
  IFNULL( `rp`.`b1w`, `fp`.`b1w` ) AS `stroke_width_1`,
  IFNULL( `rp`.`b2w`, `fp`.`b2w` ) AS `stroke_width_2`,
  IFNULL( `rp`.`b3w`, `fp`.`b3w` ) AS `stroke_width_3`,
  IFNULL( `rp`.`b4w`, `fp`.`b4w` ) AS `stroke_width_4`,
  IFNULL( `rp`.`flip_x`, `fp`.`flip_x` ) AS `flip_x`,
  IFNULL( `rp`.`flip_y`, `fp`.`flip_y` ) AS `flip_y`,
  IFNULL( `rp`.`stroke_internal_1`, `fp`.`stroke_internal_1` ) AS `stroke_internal_1`,
  IFNULL( `rp`.`stroke_front_1`, `fp`.`stroke_front_1` ) AS `stroke_front_1`,
  CURRENT_TIMESTAMP AS `created_at`,
  CURRENT_TIMESTAMP AS `updated_at`,
  `okp`.`array_index`
FROM
  (#{virtual_order_kit_position(positions)}) `okp`
  JOIN `target_category_positions` `tcp` ON `tcp`.`id` = `okp`.`target_category_position_id`
  JOIN `shapes` `s` ON `okp`.`shape_id` = `s`.`id`
  JOIN `feature_placements` `fp` ON ( `fp`.`target_kit_id` = "#{order_kit.target_kit_id}" ) AND ( `tcp`.`position_id` = `fp`.`position_id` OR `fp`.`position_id` IS NULL ) AND ( `fp`.`shape_id` = `s`.`id` OR `fp`.`shape_id` IS NULL )
  JOIN `features` `f` ON `f`.`id` = `fp`.`feature_id`
  JOIN `feature_types` `ft` ON `f`.`feature_type_id` = `ft`.`id`
  LEFT OUTER JOIN `regulation_features` `rf` ON `rf`.`regulation_id` = #{order_kit.regulation_id} AND `rf`.`position_id` = `tcp`.`position_id` AND `rf`.`feature_id` = `fp`.`feature_id`
  LEFT OUTER JOIN `regulation_placements` `rp` ON `rp`.`id` = `rf`.`placement_id`
WHERE
  `fp`.`target_category_id` IS NULL AND `fp`.`product_line_id` = #{order_kit.product_line.id} AND `f`.`visible_to_user` = 1
  AND (
       ( ( `f`.`presence_regulated` = 0 ) AND ( ifnull( `rf`.`requirement`, 0 ) > -1 ) )
    OR ( ( `f`.`presence_regulated` = 1 ) AND ( ifnull( `rf`.`requirement`, 0 ) > -1 ) )
    OR ( ( `f`.`presence_regulated` = 2 ) AND ( ifnull( `rf`.`requirement`, -1 ) > -1 ) )
 )
ORDER BY  `rf`.`regulation_id` DESC, `fp`.`shape_id` DESC, `fp`.`position_id` DESC, `fp`.`target_category_id` DESC;
SQL
  end

  def create_regulated_target_category_features_sql(positions)
    <<-SQL
SELECT
  `tcp`.`position_id`,
  `f`.`id` AS `feature_id`,
  `rf`.`id` AS `regulation_feature_id`,
  `f`.`name` AS `feature_name`,
  `ft`.`name` as `feature_type`,
  ROUND( IF(
            `rp`.`x` IS NOT NULL,
            `rp`.`x` * `s`.`editor_width`,
            IF( `fp`.`shape_id` IS NULL, `fp`.`x` * `s`.`editor_width`, `fp`.`x` )
            ), 6 ) AS `x`,
  ROUND( IF(
            `rp`.`y` IS NOT NULL,
            `rp`.`y` * `s`.`editor_height`,
            IF( `fp`.`shape_id` IS NULL, `fp`.`y` * `s`.`editor_height`, `fp`.`y` )
            ), 6 ) AS `y`,
  IFNULL( `rp`.`angle`, `fp`.`angle` ) AS `angle`,
  IFNULL( `rp`.`scale`, `fp`.`scale` ) AS `scale`,
  IFNULL( `rp`.`z_index`, `fp`.`z_index` ) AS `z_index`,
  IFNULL( `rp`.`icon_id`, `fp`.`icon_id` ) AS `icon_id`,
  IFNULL(
          IF ( `rp`.`fill_id` > 0, CONCAT('FAMREG', `rp`.`fill_id`), NULL ), # augment value marking it's origin
          `fp`.`fill_id`
        ) AS `fill_colour_id`,
  IFNULL( `rp`.`text`, `fp`.`text` ) AS `text`,
  IFNULL( `rp`.`font_size`, `fp`.`font_size` ) AS `font_size`,
  IFNULL( `rp`.`font_family_id`, `fp`.`font_family_id` ) AS `font_id`,
  IFNULL( `rp`.`alignment`, `fp`.`alignment` ) AS `text_alignment`,
  IFNULL( `rp`.`spacing`, `fp`.`spacing` ) AS `letter_spacing`,
  IFNULL( `rp`.`height`, `fp`.`height` ) AS `line_height`,
  IFNULL( `rp`.`b1f_id`, `fp`.`b1f_id` ) AS `stroke_style_1`,
  IFNULL( `rp`.`b2f_id`, `fp`.`b2f_id` ) AS `stroke_style_2`,
  IFNULL( `rp`.`b3f_id`, `fp`.`b3f_id` ) AS `stroke_style_3`,
  IFNULL( `rp`.`b4f_id`, `fp`.`b4f_id` ) AS `stroke_style_4`,
  IFNULL( `rp`.`b1w`, `fp`.`b1w` ) AS `stroke_width_1`,
  IFNULL( `rp`.`b2w`, `fp`.`b2w` ) AS `stroke_width_2`,
  IFNULL( `rp`.`b3w`, `fp`.`b3w` ) AS `stroke_width_3`,
  IFNULL( `rp`.`b4w`, `fp`.`b4w` ) AS `stroke_width_4`,
  IFNULL( `rp`.`flip_x`, `fp`.`flip_x` ) AS `flip_x`,
  IFNULL( `rp`.`flip_y`, `fp`.`flip_y` ) AS `flip_y`,
  IFNULL( `rp`.`stroke_internal_1`, `fp`.`stroke_internal_1` ) AS `stroke_internal_1`,
  IFNULL( `rp`.`stroke_front_1`, `fp`.`stroke_front_1` ) AS `stroke_front_1`,
  CURRENT_TIMESTAMP AS `created_at`,
  CURRENT_TIMESTAMP AS `updated_at`,
  `okp`.`array_index`
  FROM
    ( #{virtual_order_kit_position(positions)} ) `okp`
    JOIN `target_category_positions` `tcp` ON `tcp`.`id` = `okp`.`target_category_position_id`
    JOIN `target_categories` `tc` ON `tc`.`id` = `tcp`.`target_category_id`
    JOIN `shapes` `s` ON `okp`.`shape_id` = `s`.`id`
    JOIN `feature_placements` `fp` ON ( `fp`.`target_category_id` = `tc`.`id` OR `fp`.`target_category_id` IS NULL ) AND ( `tcp`.`position_id` = `fp`.`position_id` OR `fp`.`position_id` IS NULL ) AND ( `fp`.`shape_id` = `s`.`id` OR `fp`.`shape_id` IS NULL )
    JOIN `features` `f` ON `f`.`id` = `fp`.`feature_id`
    JOIN `feature_types` `ft` ON `f`.`feature_type_id` = `ft`.`id`
    LEFT OUTER JOIN `regulation_features` `rf` ON `rf`.`regulation_id` = #{order_kit.regulation_id} AND `rf`.`position_id` = `tcp`.`position_id` AND `rf`.`feature_id` = `fp`.`feature_id`
    LEFT OUTER JOIN `regulation_placements` `rp` ON `rp`.`id` = `rf`.`placement_id`
WHERE
      `fp`.`product_line_id` = #{order_kit.product_line.id}
      AND `fp`.`target_kit_id` IS NULL
      AND `f`.`visible_to_user` = 1
      AND (
           ( ( `f`.`presence_regulated` = 0 ) AND ( ifnull ( `rf`.`requirement`, 0 ) > -1 ) )
        OR ( ( `f`.`presence_regulated` = 1 ) AND ( ifnull ( `rf`.`requirement`, 0 ) > -1 ) )
        OR ( ( `f`.`presence_regulated` = 2 ) AND ( ifnull ( `rf`.`requirement`, -1 ) > -1 ) )
  )
ORDER BY
  `rf`.`regulation_id` DESC, `fp`.`shape_id` DESC, `fp`.`position_id` DESC, `fp`.`target_category_id` DESC;
SQL
  end


  def positions_for_target_kit
    <<-SQL
SELECT
    tcp.id      AS target_category_position_id,
    kc.shape_id AS shape_id,
    ( SELECT
        decal_id
    FROM
        shape_prices sp
        JOIN decals d ON d.id = sp.decal_id
    WHERE sp.shape_id = kc.shape_id
    ORDER BY d.price_per_m2 DESC
    LIMIT 1 )
    AS decal_id,
    kc.id AS kit_component_id,
    dmp.id AS display_map_position_id,
    1 AS quantity,
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS updated_at
FROM
    target_kits tk
    JOIN kit_components kc ON kc.kit_id = tk.kit_id
    JOIN display_maps dm ON dm.kit_id = tk.kit_id
    JOIN display_map_positions dmp ON dmp.display_map_id = dm.id AND dmp.position_id = kc.position_id
    JOIN target_category_positions tcp ON tcp.target_category_id = #{order_kit.target_category_id} AND tcp.position_id = kc.position_id
WHERE tk.id = #{order_kit.target_kit_id} AND kc.default = 1
SQL
  end

  def positions_for_target_category_kit
    <<-SQL
SELECT
  tcp.id AS target_category_position_id,
  default_shape_id AS shape_id,
  (
      SELECT
          decal_id
      FROM
        shape_prices sp
        JOIN decals d ON d.id = sp.decal_id
      WHERE
          sp.shape_id = tcp.default_shape_id
      ORDER BY d.price_per_m2 DESC LIMIT 1 ) AS decal_id,
  NULL AS kit_component_id, NULL AS display_map_position_id, 1 AS quantity, CURRENT_TIMESTAMP AS created_at, CURRENT_TIMESTAMP AS updated_at
FROM
  target_category_positions tcp
WHERE tcp.target_category_id = #{order_kit.target_category_id} AND tcp.default_shape_id NOT LIKE '%-0'
SQL
  end

  def virtual_order_kit_position(positions)
    positions.each_with_index.map do |p, index|
      "SELECT %d target_category_position_id, \"%s\" shape_id, %d array_index FROM DUAL" % [p.target_category_position_id, p.shape_id, index ]
    end.join("\nUNION ALL\n")
  end

  def apply_removals(positions)
    Rst::FAMRemovals.apply(positions: positions, connection: connection, order_kit: order_kit)
  end

  def connection
    ActiveRecord::Base.connection
  end
end
