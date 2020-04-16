module Rst
  module OrderModelsAdditions
    module ClassMethods
      def belongs_to(attribute)
        attr_accessor "#{attribute}_id".to_sym

        define_method attribute do
          return nil unless instance_variable_get("@#{attribute}_id")
          return instance_variable_get("@#{attribute}") if instance_variable_get("@#{attribute}")
          ActiveSupport::Dependencies.constantize(attribute.to_s.camelize).find( instance_variable_get("@#{attribute}_id") )
        end

        define_method "#{attribute}="  do |object|
          instance_variable_set("@#{attribute}", object)
          instance_variable_set("@#{attribute}_id", object.id) unless object.nil?
        end
      end
    end

    class HasManyCollection < DelegateClass(Array)
      def initialize(array = [])
        super(array)
      end

      def sort(&block)
        HasManyCollection.new(self.__getobj__.sort(&block))
      end

      def includes(attributes={})
        attributes.each do |k,v|
          ids = self.map {|e| e.send("#{k}_id") }
          ids = ids.uniq.compact
          if ids.any?
            objects = ActiveSupport::Dependencies.constantize(k.to_s.camelize).where(id: ids).includes(v)
            objects.each do |o|
              self.each do |item|
                item.send("#{k}=", o) if item.send("#{k}_id") == o.id
              end
            end
          end
        end

        self
      end
    end
  end
end
