# Modify data to meet ui-client expectations
module Rst
  class AddressFormatter
    # messy, address format would be better if keys were address1, address2, address3, ... - CM
    def call(r)
      address_components = r.address_format.split('|').map { |m| m.strip }

      address_format              = { address1: '', address2: '', city: '', subRegion: '', postCode: '' }
      address_format['postCode']  = address_components[-1] if address_components.length >= 1
      address_format['subRegion'] = address_components[-2] if address_components.length >= 2
      address_format['city']      = address_components[-3] if address_components.length >= 3
      address_components[0..-4].each_with_index do |a, i|
        address_format["address#{i + 1}"] = a
      end

      address_format
    end
  end
end
