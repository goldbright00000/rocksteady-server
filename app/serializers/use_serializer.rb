class UseSerializer < ActiveModel::Serializer
  #embed :ids, :include => true

  attributes :id, :name, :parent_id

  def parent_id
    object.parent.try(:id)
  end


  has_many :filtered_children, :key => :children_ids

  def filtered_children
    return object.children.map(&:id) unless instance_options.key?(:acceptable_use_ids)

    object.children
      .map(&:id)
      .delete_if {|c| !instance_options[:acceptable_use_ids].include?(c) }
  end
end
