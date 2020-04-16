class SubkitType < ActiveRecord::Base

  belongs_to :target_category
  has_many :kits

end
