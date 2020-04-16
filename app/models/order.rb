# Represents an order for a given user.
class Order
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :kits

  def initialize(attributes = {})
    super
    @kits ||= Rst::OrderModelsAdditions::HasManyCollection.new
  end
end
