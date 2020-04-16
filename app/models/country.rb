class Country < ActiveRecord::Base
  DEFAULT_ISO_CODE = 'US'.freeze # default locale if one can not be computed

  has_many :country_icons
  has_many :icons, through: :country_icons
  has_one :interview_icon

  belongs_to :currency

  scope :has_an_interview_icon, -> {
    joins("INNER JOIN interview_icons ON(interview_icons.country_id = countries.id)")
  }

  scope :only_base_columns, -> {
    select([:id, 'iso_code2 AS iso_alpha_2', :iso_numeric, :priority, :address_format, :currency_id])
  }

  def self.default
    Country.where(iso_code2: DEFAULT_ISO_CODE).take!
  end

  def default?
    iso_alpha_2 == DEFAULT_ISO_CODE
  end

  def image_url
    interview_icon.data
  end

  def available_rule_set_ids(target_category_id = nil,
        regulation_country_id: Characteristic.regulation_region.id)
    RegulationConstraint.joins(:regulation, :constraint)
      .where({}.tap do |p|
        p[:constraints] =  { exact_value: [id, Constraint::GLOBAL],
                             characteristic_id: regulation_country_id }
        p[:regulations] = { target_category_id: target_category_id } if target_category_id
      end)
      .select('DISTINCT(rule_set_id) as rule_set_id').map(&:rule_set_id)
  end
end
