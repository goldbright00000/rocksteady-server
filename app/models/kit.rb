# Specifies a kit, as a way to group components
class Kit < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :kit_type
  belongs_to :subkit_type
  has_one :display_map
  has_many :target_kits
  has_many :targets, through: :target_kits
  has_many :kit_components
  has_many :components, through: :kit_components

  def themes
    Theme.where('kit_components.kit_id = ?', id).joins(
        :theme_shapes => [:shape => :kit_components]
    ).distinct
  end

  def colours
    Colour.where(id: colour_ids)
  end

  protected

  def colour_ids
    kit_components.joins(:component =>
                             [:colour_palette =>
                                  :colour_palette_colours]
    ).pluck('colour_palette_colours.colour_id').uniq
  end
end
