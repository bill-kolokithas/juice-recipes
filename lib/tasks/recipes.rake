namespace :recipes do
  desc "Import data from json file as argument"
  task :import, [:filename] => [:environment, :recreate] do |t, args|
    id = errors = 0
    data = JSON.parse(File.read(args.filename))

    data['results'].each do |recipe|
      name = recipe['collection1'][0]['property1']['text']
      photo = recipe['collection1'][0].fetch('property2', {})['src']

      tags = recipe['collection1'][0]['property5']['text']
      tags = tags[6..-1].split(', ') unless tags.nil?

      votes = recipe['collection2'][0]['property3']
      average = recipe['collection2'][1]['property3']

      ingredients = []
      recipe['collection3'].try(:each) { |ingredient| ingredients << ingredient['property4'] }
      next if ingredients[0].class == Hash # catch malformed case

      # We could reuse 'new' object and gain speed but 'new_record?' will return false for all records except first
      new = Juice.new
      new.id = id += 1
      new.name = name
      new.suggest_name = {
        input: name.split,
        output: name,
        payload: { url: "/juices/#{id}" }
      }
      new.photo = photo
      new.votes = votes
      new.average = average
      new.tags = tags
      new.ingredients = ingredients

      unless new.save
        errors += 1
        id -= 1 # don't leave gaps
      end
    end

    puts "#{ActionController::Base.helpers.pluralize(id, 'document')} imported, #{errors} failed"
  end

  desc "Re-create index"
  task recreate: :environment do
    Juice.gateway.create_index! force: true
  end
end
