namespace :recipes do
  desc "Import data from json file as argument"
  task :import, [:filename] => [:environment, :recreate] do |t, args|
    id = errors = 0
    data = JSON.parse(File.read(args.filename))

    data.each do |recipe|
      next if !recipe['collection1'].present?
      name = recipe['collection1'].first['name']

      next if !recipe['collection2'].present?
      photo = recipe['collection2'].first['image']
      photo = File.basename(photo)

      next if !recipe['collection3'].present?
      votes = recipe['collection3'].first['rating']
      average = recipe['collection3'].second['rating']

      next if !recipe['collection4'].present?
      ingredients = recipe['collection4'].map { |ingredient| ingredient['ingredients'] }
      next if ingredients.first.class == Hash # catch malformed case

      next if !recipe['collection5'].present?
      tags = recipe['collection5'].first['tags']
      tags = tags.split(', ')

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
      new.ingredients = ingredients
      new.tags = tags

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
