module ApplicationHelper
  def is_integer?(s)
    Integer(s) rescue false
  end

  def names_to_ids(params)
    #
    #   This is set by Harcourt when testing
    #
    return unless params[:system_testing]

    logger.debug "Params came in: #{params.inspect}"

    # PRODUCT LINE
    if params[:product_line_name].present?
      product_line             = ProductLine.find_by_name params[:product_line_name]
      params[:product_line_id] = product_line.id
    elsif params[:product_line_id]
      product_line = ProductLine.find params[:product_line_id]
    end

    params[:manufacturer_id] = Manufacturer.unscoped.where(name: params[:manufacturer_id]).pluck(:id)[0] if params[:manufacturer_id].present?
    params[:user_flag]  = Country.where(name: params[:user_flag]).limit(1).pluck(:id)[0] if params[:user_flag].present?
    params[:region_id]       = Country.where(name: params[:region_id]).limit(1).pluck(:id)[0] if params[:region_id].present?

    # TARGET
    if params[:target_id].present? && product_line.present?
      target             = Target.unscoped.where(
          name:           params[:target_id],
          target_type_id: product_line.target_type_id
      ).first!
      target_category_id = target.target_category_id
      params[:target_id] = target.id
    end

    # TARGET KIT
    if params[:target_id].present? && params[:target_kit_id].present?
      params[:target_kit_id] = TargetKit.where(
          target_id:       params[:target_id],
          qualifying_data: params[:target_kit_id]
      ).pluck(:id)[0]

      throw RecordNotFound "target kit #{params[:target_kit_id]} not found" if params[:target_kit_id].blank?
    end

    # TARGET CATEGORY
    if product_line.present? && params[:target_category_id].present?
      params[:target_category_id] = product_line.target_categories.where(name: params[:target_category_id]).pluck(:id)[0]
    elsif target_category_id.present?
      params[:target_category_id] = target_category_id
    end

    # USE
    if params[:use_id].present? && !is_integer?(params[:use_id])
      params[:use_id] = UseTest.find_by_path(params[:use_id])

      throw RecordNotFound "Use level [#{params[:target_kit_id]}] not found" if params[:use_id].blank?
    end

    params[:use_category_id] = UseCategory.unscoped.where(name: params[:use_category_id]).pluck(:id)[0] if params[:use_category_id].present?
    params[:rule_set_id]     = product_line.rule_sets.where(name: params[:rule_set_id]).pluck(:id)[0] if params[:rule_set_id].present?

    logger.debug "Params translated: #{params.inspect}"

    # puts params

    nil
  end

  # Get values from the supplied ids array, that are not in the given table
  #
  # @param [String] tablename
  # @param [Array] ids
  # @return Array
  def ids_not_in_table(ids, tablename)
    sql_ids = ids.map { |i|
      i = 'NULL' if i.blank?
      "#{i} AS id"
    }.join ' UNION SELECT '

    sql = <<-SQL
      SELECT
        `virtual`.`id`
      FROM ( SELECT #{sql_ids} )
          AS `virtual`
      WHERE
        `virtual`.`id` NOT IN (
          SELECT
            `i`.`id`
          FROM
            `#{tablename}` `i`
        )
    SQL

    ActiveRecord::Base.connection.execute(sql).to_a
  end

end
