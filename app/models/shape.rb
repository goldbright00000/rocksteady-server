##
# A Shape defines the outline for the piece (or pieces) of Decal that the Customer receives.
#
# It currently also stores the Shape for a single layer of a Theme - probably a bad idea as the ThemeShape doesn't need the cuts/backdrop/area.
#
# product_line_id     Which #ProductLine is the #Shape used in
# internal_id         Internal reference to the #Shape, managed by the Kit Team, each TargetType has it's own
#                     collection of internal references starting at 1.
# name                Some shapes have a name
# component_svg       The outline of the shape rendered as the Background Feature in the Editor/Selector.
#                     Before saving we coalesce any Polygons and Polylines into a single path element.
# backdrop_svg        At some point this was meant to hold a backdrop image to be shown in the editor.  Likely
#                     this should be an image of the Component and belongs there.
# throughcut_svg      The Cutter uses this to cut the printed item from the Decal sheet.
# kisscut_svg         If there is more than one piece to the printed item, or there are pieces to be thrown away
# bleedcut            used to extend colour beyond throughcut so no white margin when shep is cut
#                     the Kisscut is used to provide the outline(s) for the Cutter so that the pieces may be
#                     provided on a single piece of #Decal.
# editor_width        Width of the SVG
# editor_height       Height of the SVG
# print_area          Currently set to 1, will be replaced with the area inside the Shape's outline.
# multiple_positions  Does the shape cover more than one #Position ?
#
class Shape < ActiveRecord::Base
  belongs_to :product_line

  has_many :components, foreign_key: 'default_shape_id'
  has_many :kit_components
  has_many :target_category_shapes, foreign_key: 'default_shape_id'
  has_many :shape_prices
  has_many :theme_shapes
  has_many :themes, through: :theme_shapes

  # Where we don't have SVGs for a Component we use the None shape
  def self.none
    @none ||= first
  end

  # Each Shape has a collection of prices - one for each Decal it's available on
  def decal_prices(decal_ids, apply_percentage_discount: BigDecimal.new(0))
    shape_prices.where(decal_id: decal_ids).map do |sp|
      { decal_id: sp.decal_id, price: (sp.price - sp.price * apply_percentage_discount).to_f  }
    end
  end

  def as_hash(available_decal_ids, apply_percentage_discount: BigDecimal.new(0))
    {
        id:                         id,
        internal_id:                internal_id,
        name:                       name,
        #url: '',
        # TODO defer loading
        svg:                        component_svg,
        width:                      editor_width.to_f,
        height:                     editor_height.to_f,
        print_offset:               {
            x: print_offset_x.to_f,
            y: print_offset_y.to_f
        },
        qron:                       {
            centre_x: qron_x.to_f,
            centre_y: qron_y.to_f,
            rotation: qron_rotation.to_f,
        },
        decal_prices:               decal_prices(available_decal_ids, apply_percentage_discount: apply_percentage_discount),
        shareable:                  !multiple_positions,
        initial_feature_position:   visible_centre_point.present? ? 'centre' : 'last',
        component_curvature_rating: component_curvature_rating,
        perforated_shape_warning:   perforated_shape_warning ? true : false
    }
  end

end
