class PostalOption < ActiveRecord::Base
  has_many :shipping_option
end