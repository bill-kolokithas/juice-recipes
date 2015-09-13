class JuicesController < ApplicationController
  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: 'public/404.html', status: 404, layout: false
  end

  def index
    session[:init] = true
    @params = params.permit(:q, :color, :page, :sort, :filter, filter: [])

    filters = []
    if @params[:filter].present?
      [@params[:filter]].flatten.each do |ingredient|
        filters << { term: { 'ingredients.filtered': ingredient } }
      end
    end

    if @params[:color].present?
      filters << { term: { tags: @params[:color] } }
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

    query = {
      query: {
        multi_match: {
          query: @params[:q],
          fields: [ 'name', 'ingredients' ]
        }
      }
    }

    combined_score = {
      query: {
        function_score: {
          field_value_factor: { field: 'score' },
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

    request = paginate(@params[:page]).merge(aggregation_terms).merge!(query_filter)
    request.merge!(sort_score) if @params[:sort].present? && !@params[:q].present?
    @juices = Juice.search request

    if @juices.empty?
      render layout: true, inline:
        '<div class="text-center">
           <h4> No results found </h4>
         </div>'
    end
  end

  def show
    @juice = Juice.find(params[:id])
  end

  def update
    session[:voted] ||= []
    params.require(:juice)
    @juice = Juice.find(params[:id])
    @juice.rating = params[:juice][:rating].to_i
    @juice.votes += 1

    if @juice.save
      session[:voted] << @juice.id
    else
      render nothing: true
    end
  end

  def suggest
    render json: Suggester.new(params)
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
