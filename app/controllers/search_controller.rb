class SearchController < ApplicationController
  before_action only: :index do
    non_empty_param(params[:q])
  end

  before_action only: :filter do
    non_empty_param(params[:color])
  end

  def index
    @params = params.slice(:q, :page)

    case params[:sort]
    when 'score'
      sort_field = 'score'
    when 'combined'
      sort_field = 'combined'
    else
      sort_field = '_score'
    end

    query = {
      query: {
        multi_match: {
          query: params[:q],
          fields: [ 'name', 'ingredients' ]
        }
      }
    }

    if sort_field == 'combined'
      @juices = Juice.search pagination(params[:page]).merge(
        query: {
          function_score: {
            field_value_factor: { field: 'score' },
            boost_mode: 'sum'
          }.merge(query)
        }
      )
    else
      @juices = Juice.search pagination(params[:page]).merge(query.merge(
        sort: { sort_field => "desc" }
      ))
    end
  end

  def filter
    @juices = Juice.search pagination(params[:page]).merge(
      filter: {
        term: { tags: params[:color] }
      }
    )
  end

  def suggest
    render json: Suggester.new(params)
  end

  private

  def non_empty_param(param)
    redirect_to juices_path unless param.present?
  end
end
