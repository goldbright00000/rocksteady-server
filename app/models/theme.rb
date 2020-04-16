class Theme < ActiveRecord::Base
  belongs_to :target_category
  belongs_to :target_kit
  belongs_to :target
  belongs_to :product_line
  belongs_to :author, class_name: "ThemeAuthor", counter_cache: true
  belongs_to :category, class_name: "ThemeCategory"
  belongs_to :regulation
  has_many :theme_tags

  has_many :theme_linked_features

  has_many :linked_features, through: :theme_linked_features, source: :feature, class_name: 'Feature'

  has_many :prompted_features, -> { where('features.prompt = 1') }, through: :theme_linked_features, source: :feature, class_name: 'Feature'

  has_many :target_category_positions, through: :theme_linked_features, source: :target_category_position

  has_many :previews, class_name: 'ThemePreview'

  scope :visible, -> { where(visible: true) }

  def external_id
    "#{product_line.id}-#{spreadsheet_row_id}"
  end

  def self.find_by_external_id(id)
    if match = id.match(/^(\d+)-(\d+)$/)
        visible.find_by(product_line_id: $1, spreadsheet_row_id: $2) or raise ActiveRecord::RecordNotFound.new("Couldn't find Theme with 'id'=#{id}")
    else
      raise ActiveRecord::RecordNotFound.new("Couldn't find Theme with 'id'=#{id}")
    end
  end

  # @param [Hash] params
  #    ?product_line_name=XX&manufacturer_name=XX&target_name=XX&target_category_name=XX&grouped_year=XX
  def self.by_query_params(params)
    product_line = ProductLine.find_by_name params[:product_line_name]

    if params[:manufacturer_name].present?
      manufacturer = product_line.manufacturers.where(:name => params[:manufacturer_name]).take!
    end

    if params[:target_name].present?
      query_opts = { name: params[:target_name] }
      query_opts[:manufacturer_id] = manufacturer.id if manufacturer

      target = product_line.targets.where(query_opts).reorder('').take!

      if params[:grouped_year].present?
        target_kit_id = target.target_kits.select('target_kits.id').where(qualifying_data: params[:grouped_year]).take!
      else
        target_category_id = target.target_category_id
      end
    elsif params[:target_category_name].present?
      target_category_id = product_line.target_categories.select('target_categories.id').where(name: params[:target_category_name]).take!
    end

    if target_kit_id.present?
      filter = { target_kit_id: target_kit_id, product_line_id: product_line.id }
    elsif target_category_id.present?
      filter = { target_kit_id: nil, target_category_id: target_category_id, product_line_id: product_line.id }
    end

    visible.includes(regulation: [:use_category, :rule_set, :use], author: [:country],
                     category: [], theme_tags: [:category], previews: [], product_line: []).where(filter)
  end
end
