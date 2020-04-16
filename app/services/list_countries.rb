class ListCountries
  def self.call(*params)
    new.call(*params)
  end

  def call(collection: [], address_formatter: Rst::AddressFormatter.new,
            decorated_class: DecoratedCountry )

    collection = collection.map { |c| decorated_class.new(c) }

    encode(collection, address_formatter: address_formatter)
  end

  private

  def encode(collection, address_formatter: Rst::AddressFormatter.new)
    return collection unless address_formatter
    collection.each { |r| r.formatted_address = address_formatter.(r) }
  end

  class DecoratedCountry < SimpleDelegator
    attr_accessor :formatted_address

    def address_format
      formatted_address || __getobj__.address_format
    end

    def as_json(options = {})
      {id: id, priority: priority, currency_id: currency_id, address_format: address_format,
       iso_numeric: iso_numeric, iso_alpha_2: iso_alpha_2, image_url: image_url, graphic_id: icon_ids.first }
    end
  end
end
