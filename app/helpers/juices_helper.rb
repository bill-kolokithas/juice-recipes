module JuicesHelper
  def filter_add_remove(params, filter)
    params.merge(filter: filter) { |_, old, new| old.include?(new) ? [old].flatten - [new] : [old, new].flatten }
  end
end
