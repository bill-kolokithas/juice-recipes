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

  def merge_highlighted_ingredients(juice)
    if session[:highlight].try(:[], juice.id)
      session[:highlight][juice.id].each do |ingredient|
        idx = juice.ingredients.index(strip_tags(ingredient))
        juice.ingredients[idx] = ingredient
      end
    end
    juice.ingredients
  end
end
