module ActiveRecord
  class Relation

    def take_or_create(attributes = nil, &block)
      take || create(attributes, &block)
    end

    def take_or_create!(attributes = nil, &block)
      take || create!(attributes, &block)
    end

    def take_or_initialize(attributes = nil, &block)
      take || new(attributes, &block)
    end

  end
end
