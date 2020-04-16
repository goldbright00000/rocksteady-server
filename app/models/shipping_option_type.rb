class ShippingOptionType < ActiveRecord::Base
  has_many :shipping_option

  FREE      = 'Free'
  STANDARD  = 'Standard'
  EXPEDITED = 'Expedited'

end