# Defines what the use of the target will
# be. For example, International Six Day -
# Women (2 Stroke).
class Use < ActiveRecord::Base
  acts_as_nested_set

  has_many :regulations
  has_many :use_categories, through: :regulations

  def full_name(separator: '/')
    if parent
      "#{parent.full_name(separator: separator)}#{separator}#{name}"
    else
      name
    end
  end

  def full_name_as_array
    full_name.split '/'
  end

end
