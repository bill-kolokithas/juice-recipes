module JuicesHelper
  def filter_add_remove(params, filter)
    params.merge(filter: filter) do |_, old, new|
      if old.try(:include?, new)
        [old].flatten - [new] # remove ingredient
      else
        old.blank? ? new : [old, new].flatten
      end
    end
  end
end
