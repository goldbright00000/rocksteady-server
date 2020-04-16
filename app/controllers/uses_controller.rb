class UsesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: Proc.new { |e| render_error(e.message) }

  def index
    render_error('Please specify a Target or TargetCategory') unless required_params?

    acceptable_use_ids = source.acceptable_use_ids(rule_set.id, use_category_id)
    use_roots = Use.roots.where(:id => acceptable_use_ids).order(:name)

    use_children = use_roots
                   .map(&:descendants)
                   .flatten
                   .uniq
                   .reject {|c| !acceptable_use_ids.include?(c.id) }


    render json: { uses: ActiveModel::Serializer::CollectionSerializer.new(use_roots.all, root: false, :acceptable_use_ids => acceptable_use_ids),
                   uses_children:  ActiveModel::Serializer::CollectionSerializer.new(use_children, root: false, :acceptable_use_ids => acceptable_use_ids),
    }
  end

  private

  def source
    if params[:target_id].present?
      Target.find params[:target_id]
    elsif params[:target_category_id].present?
      TargetCategory.find params[:target_category_id]
    end
  end

  def required_params?
    params.key?(:target_id) || params.key?(:target_category_id)
  end

  def rule_set
    RuleSet.find(params[:rule_set_id])
  end

  def use_category_id
    params[:use_category_id]
  end
end
