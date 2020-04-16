class ThemeAuthorSerializer < ActiveModel::Serializer
  attribute :themes_count, key: :designs
  attributes :nationality, :name, :speciality

  def nationality
    {
      country_name: object.country.name,
      region_id:    object.country.id,
    }
  end

  def speciality
    JSON.parse(object.speciality_json_badge)
  rescue
    {} # Benign value
  end
end
