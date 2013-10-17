require 'rubygems' # Helps find gems like mongo that aren't in the load path for some reason.
require 'mongo' # Allows us to connect to mongo
require_relative 'google_oauth'

include Mongo


# Retrieves a single tweet from the database at a specified index.
def getTweet(index)
  @client = MongoClient.new('localhost', 27017)
  @db     = @client['undergrad_research']
  @coll   = @db['tweets']
  items = @coll.find({}, {limit:1, skip:index})
  return items
end


output_filename = 'training_list.txt'
total_examples = 500

File.open(output_filename, 'w') do |file|
  current = 0
  # TODO: Instead, query the database once, loop through the results.
  begin
    item = getTweet(current).next()
    if (item.empty?) then break end # No more tweets!
    
    if (!item['text']) then next end # If the tweet is malformed, move to the next one
      
    file.write(item['text'] + "\n")
  
    current += 1
  end while (current < total_examples)
end

puts "Training list created at #{output_filename}."
