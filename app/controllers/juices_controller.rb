class JuicesController < ApplicationController
  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: 'public/404.html', status: 404, layout: false
  end

  def index
    @params = params.slice(:page)
    sort_field = params.key?(:sort) ? 'score' : '_score'
    @juices = Juice.all pagination(params[:page]).merge(
      sort: { sort_field => 'desc' }
    )
  end

  def show
    @juice = Juice.find(params[:id])
  end

  def update
    params.require(:juice).permit(:rating)
    @juice = Juice.find(params[:id])
    @juice.rating = params[:juice][:rating].to_i
    @juice.votes += 1

    render nothing: true unless @juice.save
  end
end
