class RegulationPlacement < ActiveRecord::Base

  belongs_to :b1f, foreign_key: 'b1f_id', class_name: 'Colour'
  belongs_to :b2f, foreign_key: 'b2f_id', class_name: 'Colour'
  belongs_to :b3f, foreign_key: 'b3f_id', class_name: 'Colour'
  belongs_to :b4f, foreign_key: 'b4f_id', class_name: 'Colour'
  belongs_to :colour, foreign_key: 'fill_id'
  belongs_to :font, foreign_key: 'font_family_id'
  belongs_to :icon
  belongs_to :position
  belongs_to :product_line
  belongs_to :shape
  belongs_to :target_category
  has_many :regulation_features, foreign_key: 'placement_id'

  def top
    y
  end

  def left
    x
  end

end
