class JuicesController < ApplicationController
  include QueryPlanner

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: 'public/404.html', status: 404, layout: false
  end

  def index
    # Clear highlighting
    session[:ingredients] = {}
    session[:tags] = {}

    @params = params.permit(:q, :color, :page, :sort, :filter, filter: [])
    @juices = Juice.search query_planner(@params)

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
    # Don't alter session when ajax autocompletion is used
    request.session_options[:skip] = true
    render json: Suggester.new(params)
  end
end
