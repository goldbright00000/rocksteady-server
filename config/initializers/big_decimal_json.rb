require 'bigdecimal'

class BigDecimal
  def as_json(_options = nil) #:nodoc:
    if finite?
      self
    else
      NilClass::AS_JSON
    end
  end
end
