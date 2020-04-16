class ThemeSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :previews, :filters, :flags, :category, :design_time, :regulation, :description
  belongs_to :author, serializer: ThemeAuthorSerializer, key: :designer

  def id
    object.external_id
  end

  def name
    object.display_name
  end

  def price
    object.price_multiplier.to_f
  end

  def flags
    [
      {
        name: "New",
        value: object.new
      },
      {
        name: "Popular",
        value: object.popular
      }
    ]
  end

  def category
    object.category.name
  end

  def filters
    ordered_tags(object.theme_tags)
  end

  def regulation
    return nil unless regulation = object.regulation
    {
      name: regulation.name(separator: ' / '),
      image: regulation.use_category.data
    }
  end

  def previews
    object.previews.map  {|p| { name: p.name, image_url: p.path } }
  end

  private

  def ordered_tags(tags)
    tags.group_by { |tag| tag.category.name }
    .map do |k,v|
      ordered_values =  v.sort_by(&:spreadsheet_order)
                         .map(&:name)
      { name: k, ordered_values: ordered_values }
    end
  end

end
