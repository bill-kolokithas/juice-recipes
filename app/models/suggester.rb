class Suggester
  attr_reader :response

  def initialize(params={})
    @term = params[:term]
  end

  def response
    @response ||= Juice.gateway.client.suggest index: Juice.index_name,
      body: {
        juices: {
          text: @term,
          completion: {
            field: 'suggest_name', size: 10, fuzzy: true
          }
        }
      }
  end

  def as_json(options={})
    response
      .except('_shards')
      .reduce([]) do |sum, d|
        item = { :label => d.first.titleize, :value => d.second.first['options'] }
        sum << item
      end
  end
end
