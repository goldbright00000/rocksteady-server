# This module provides an Entity-Attribute-Value setup for ActiveRecord models
# with the names of the fields controlled by the Property table
module EAVFields

  extend ActiveSupport::Concern

  module ClassMethods

    def eav_fields(options = {})

      entity_class_name = self.table_name.singularize

      attribute_class_name = (options[:source] || :property).to_s
      attribute_class = attribute_class_name.classify.constantize

      value_field_name = (options[:value] || :value)
      value_class_name = "#{entity_class_name}_#{attribute_class_name}"
      value_class = value_class_name.classify.constantize

      has_many value_class_name.pluralize.to_sym
      has_many attribute_class_name.pluralize.to_sym,
               through: value_class_name.pluralize.to_sym

      attribute_class.all.each do |attribute|

        attribute_name = attribute.name.parameterize.underscore.downcase

        define_method(attribute_name.to_sym) do
          values = value_class.where("(#{entity_class_name}_id = ?) AND (#{attribute_class_name}_id = ?)", id, attribute.id).map(&value_field_name.to_sym)
          if values.length > 1
            values
          else
            case attribute.value_type
              when 'String'
                result = values[0]
              when 'BigDecimal'
                result = values[0].to_d
              else
                result = eval("#{attribute.value_type}(#{values[0]})")
            end
            result
          end
        end

        define_method("#{attribute_name}=".to_sym) do |values|
          [values].flatten.each do |value|
            value_record = value_class.send("find_by_#{entity_class_name}_id_and_#{attribute_class_name}_id", id, attribute.id)
            unless value_record
              value_record = value_class.new
              value_record.send("#{entity_class_name}_id=", id)
              value_record.send("#{attribute_class_name}_id=", attribute.id)
            end
            value_record.send("#{value_field_name}=", value)
            value_record.save!
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, EAVFields
