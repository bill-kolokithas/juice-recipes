class JuicesController < ApplicationController
  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: 'public/404.html', status: 404, layout: false
  end

  def index
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

    function_score = {
      query: {
        function_score: {
          field_value_factor: { field: 'score' },
          boost_mode: 'sum'
        }.merge(query)
      }
    }

    query_filter = {
      query: {
        filtered: {
          filter: {
            bool: {
              must: filters
            }
          }
        }.merge(@params[:q].present? ? (@params[:sort].present? ? function_score : query) : {})
      }
    }

    #TODO refactor the conditional mess a bit

    request = pagination(@params[:page]).merge(aggregation_terms)

    if @params[:filter].present? || @params[:color].present?
      request.merge!(query_filter)
    elsif @params[:q].present?
      request.merge!(@params[:sort].present? ? function_score : query)
    end
    if @params[:sort].present? && !@params[:q].present?
      request.merge!(sort: { score: 'desc' })
    end

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
    params.require(:juice)
    @juice = Juice.find(params[:id])
    @juice.rating = params[:juice][:rating].to_i
    @juice.votes += 1

    render nothing: true unless @juice.save
  end

  def suggest
    render json: Suggester.new(params)
  end

  private

  def pagination(page)
    page = page.to_i
    page = params[:page] = 1 if page < 1
    { size: PER_PAGE, from: PER_PAGE * (page - 1) }
  end
end
