class SeriesSponsor < ActiveRecord::Base
  has_many :series_sponsor_icons
  has_many :icons, through: :series_sponsor_icons
end
