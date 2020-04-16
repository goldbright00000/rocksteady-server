module Rst
  module FAMRemovals
    extend self

    DELETES = {
        'vv' => Proc.new { |positions, row|

          positions.each do |position|
            position.order_kit_position_features.each do |feature|
              if feature.position_id == row['position_id'] &&
                 feature.feature_id  == row['feature_id']
                position.order_kit_position_features.delete feature
              end
            end
          end
        },

        '*v' => Proc.new { |positions, row|

          positions.each do |position|
            position.order_kit_position_features.each do |feature|
              if feature.feature_id  == row['feature_id']
                position.order_kit_position_features.delete feature
              end
            end
          end
        },

        'v*' => Proc.new { |positions, row|
          positions.each do |position|
            position.order_kit_position_features.each do |feature|
              if feature.position_id  == row['position_id']
                position.order_kit_position_features.delete feature
              end
            end
          end
        },

        '**' => Proc.new { |positions, _row|
          positions.each do |position|
            position.order_kit_position_features.each do |feature|
              position.order_kit_position_features.delete feature
            end
          end
        }
    }

    def apply(connection: ActiveRecord::Base.connection, positions: position, order_kit:)
      removals = global_removals(connection, order_kit.product_line_id) +
                 target_category_removals(connection, order_kit.product_line_id, order_kit.target_category_id) +
                 target_kit_removals(connection, order_kit.product_line_id, order_kit.target_kit_id)

      remove_features(positions, removals)

      positions
    end

    def target_kit_removals(db_connection, product_line_id, target_kit_id)
      return [] if target_kit_id.blank?

      sql = <<-SQL
      SELECT
        `position_id`,
        `feature_id`
      FROM
        `feature_placement_removals`
      WHERE
        `product_line_id` = #{product_line_id}
        AND `target_kit_id` = #{target_kit_id}
      SQL
      db_connection.select_all(sql).to_a
    end

    def target_category_removals(db_connection, product_line_id, target_category_id)
      return [] if target_category_id.blank?

      sql = <<-SQL
      SELECT
        `position_id`,
        `feature_id`
      FROM
        `feature_placement_removals`
      WHERE
        `product_line_id` = #{product_line_id}
        AND `target_category_id` = #{target_category_id}
      SQL
      db_connection.select_all(sql).to_a
    end

    def global_removals(db_connection, product_line_id)
      sql = <<-SQL
      SELECT
        `position_id`,
        `feature_id`
      FROM
        `feature_placement_removals`
      WHERE
        `product_line_id` = #{product_line_id}
        AND `target_category_id` IS NULL
        AND `target_kit_id` IS NULL
      SQL
      db_connection.select_all(sql).to_a
    end

    def remove_features(positions, removals)
      return unless removals.size > 0

      map_to_deletes(positions, removals)
    end

    private

    def to_pattern(removal)
      removal.values.each.map { |c| c.nil? ? '*' : 'v' }.join
    end

    #
    #   We build a hash which maps the type of removal to a Proc handler for that type
    #   The handler returns either nil or a SQL delete statement which runs against the
    #   order_kit_position_features table to remove the feature.
    #
    #   Handlers being a Proc can be arbitrarily complex.
    #
    #   The pair of characters refers to the state of (Position, Feature) so
    #   ** means remove from all Positions and all Features
    #   vv means remove from a particular value of Position and a particular Features
    #
    #
    def map_to_deletes(positions, removals)
      _return = removals.map do |removal|
        pattern = to_pattern(removal)

        handler = DELETES[pattern]

        if handler.present?
          handler.call(positions, removal)
        else
          #
          #   We should log this as a warning
          #
          puts "(W) Missing handler for #{pattern}"
        end
      end
    end

  end
end
