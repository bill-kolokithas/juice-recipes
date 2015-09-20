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

  def merge_highlighted_results(juice, term)
    if session[term].try(:[], juice.id)
      session[term][juice.id].each do |highlighted|
        juice.send(term).map! do |original|
          original == strip_tags(highlighted) ? highlighted : original
        end
      end
    end
    juice.send(term)
  end
end
