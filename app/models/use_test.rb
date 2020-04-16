# class used only in tests, hiding everything that is testing specific from the real world
class UseTest < Use

#   This is used for testing at the command line - it shouldn't
#   be made known by clients because of the obvious overhead
#
#   The path is a string like 'Expert/E2' which can be used to find
#   the actual id required for the use
#
  def self.find_by_path(path)
    steps = path.split('/')

    root = self.where(name: steps[0], parent_id: nil).first

    #
    #   Early exit if the root is missing
    #
    return nil unless root

    result = root

    1.upto(steps.size - 1) do |depth|
      children = result.children

      result = children.find { |c| c.name == steps[depth] }
    end

    result.id
  end
end
