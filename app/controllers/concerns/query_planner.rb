module QueryPlanner
  extend ActiveSupport::Concern

  def query_planner(params)

    filters = []
    if params[:filter].present?
      [params[:filter]].flatten.each do |ingredient|
        filters << { term: { 'ingredients.filtered': ingredient } }
      end
    end

    if params[:color].present?
      filters << { term: { 'tags.raw': params[:color] } }
    end

    aggregation_terms = {
      aggs: {
        filtered_ingredients: {
          terms: {
            field: 'ingredients.filtered',
            size: 0
          }
        }
      }
    }

    highlight = {
      highlight: {
        pre_tags: ['<mark>'],
        post_tags: ['</mark>'],
        fields: {
          ingredients: { number_of_fragments: 3 }
        }
      }
    }

    query = {
      query: {
        multi_match: {
          query: params[:q],
          fields: [
            'name^10',
            'ingredients^5',
            'tags'
          ]
        }
      }
    }

    combined_score = {
      query: {
        function_score: {
          field_value_factor: {
            field: 'score',
            factor: 2
          },
          boost_mode: 'sum'
        }.merge(query)
      }
    }

    random_score = {
      query: {
        function_score: {
          random_score: { seed: session.id },
          boost_mode: 'replace'
        }
      }
    }

    sort_score = {
      sort: { score: 'desc' }
    }

    query_filter = {
      query: {
        filtered: {
          filter: {
            bool: {
              must: filters
            }
          }
        }.merge(query_plan(combined_score, query, random_score))
      }
    }

    request = paginate(params[:page]).merge(aggregation_terms).merge!(query_filter)
    if @params[:q].present?
      request.merge!(highlight)
    elsif @params[:sort].present?
      request.merge!(sort_score)
    end

    request
  end

  private

  def paginate(page)
    page = page.to_i
    page = params[:page] = 1 if page < 1
    { size: PER_PAGE, from: PER_PAGE * (page - 1) }
  end

  def query_plan(combined_score, query, random_score)
    if params[:q].present?
      if params[:sort].present?
        combined_score
      else
        query
      end
    elsif !params[:sort].present?
      random_score
    else
      {}
    end
  end
end
