class ThemeAuthor < ActiveRecord::Base
  has_many :themes
  belongs_to :country, foreign_key: :country_iso_code2, primary_key: :iso_code2
end
