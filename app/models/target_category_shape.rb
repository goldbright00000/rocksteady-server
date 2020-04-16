class TargetCategoryShape < ActiveRecord::Base

  belongs_to :shape
  belongs_to :target_category_position

  delegate :as_hash,
           to: :shape

end
