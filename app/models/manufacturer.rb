class Manufacturer < ActiveRecord::Base

  MOTOCAL = lambda { Manufacturer.where(name: 'Motocal').take_or_create! }

  belongs_to :colour_palette
  belongs_to :font_palette
  has_many :icons, through: :target_icons
  has_many :interview_icon_manufacturers
  has_many :interview_icons, through: :interview_icon_manufacturers
  has_many :target_icons
  has_many :targets
  has_one :interview_icon_manufacturer
  has_one :interview_icon, through: :interview_icon_manufacturer

  default_scope { order('manufacturers.name ASC') }

  def image_url
    image
  end

  def image
    interview_icon.present? ? interview_icon.data : ''
  end
end
