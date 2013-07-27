#!/usr/bin/env ruby
require 'rubygems' # Helps find gems like mongo that aren't in the load path for some reason.
require 'uri'
require 'net/http'
require 'net/https'
require 'mongo' # Allows us to connect to mongo
require 'logger' # Allows file logging
require 'json'
require_relative 'google_oauth'

include Mongo

=begin

Tasks:
  -Write full OAuth code for automatic Google API authorization (currently needs to be done manually)
  -Write code to handle errors that may occur with various calls to Google.
=end

# ----- Method Declarations ----- #

# Returns an array of tweets
def load_tweet_collection(database, collection, num_rows, skip_num)
  @client = MongoClient.new('localhost', 27017)
  @db     = @client['undergrad_research']
  @coll   = @db['tweets']
  puts "Preparing to retrieve the last " + num_rows.to_s + " rows from database after skipping the very last " + skip_num.to_s + " rows.\n\n"
  items = @coll.find({text: { '$exists' => true }, coordinates: { '$exists' => true }, created_at: { '$exists' => true } }, {:fields => ["text", "coordinates", "created_at"], :sort => ["_id", Mongo::DESCENDING], :skip => skip_num})
  return items
end


# Sends data from filename to the Fusion Table identified by the access token and table id.
def send_data_to_fusion (filename, access_token, table_id, content_length)
  # Create the HTTP object
  uri = URI.parse('https://www.googleapis.com/upload/fusiontables/v1/tables/' + table_id + '/import')
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  https.set_debug_output(Logger.new("http.log"))

  # Stream the data from a file to avoid  memory issues.
  req = Net::HTTP::Post.new(uri.path)
  req['Authorization'] = 'Bearer ' + access_token
  req['Content-Type'] = 'application/octet-stream'
  req['Content-Length'] = content_length
  req['Transfer-Encoding'] = 'chunked'
  response = nil;
  File.open(filename, 'r') do |file|
    req.body_stream=file
    response = https.request(req)
  end

  # Clean up temporary file afterwards
  File.delete("tempdata.txt")

  return response
end


# ----- Script ----- #

# Parse command arguments
if ARGV.index('--help') != nil
  puts "Use --rows <number> to specify how many rows to push.\nUse --skip <number> to specify how many rows to skip from the end of the results."
  exit
end

row_index = ARGV.index('--rows')
if row_index != nil
  rows = ARGV[row_index + 1]
  if rows == nil
    puts 'You did not submit a row quantity.'
    exit
  end
  rows = rows.to_i
  if rows == 0 || rows < 0
    puts 'Invalid row quantity. Please provide an integer greater than 1'
    exit
  end
else
  rows = 100
end

skip_index = ARGV.index('--skip')
if skip_index != nil
  skip = ARGV[skip_index + 1]
  if skip == nil
    puts 'You supplied the --skip option but did not submit a skip number.'
    exit
  end
  skip = skip.to_i
  if skip < 0
    puts 'You cannot skip negative rows. Please enter a positive number.'
    exit
  end
else
  skip = 0
end

# Begin the real work

all_items = load_tweet_collection('undergrad_research', 'tweets', rows, skip)

# A header is required for Fusion Tables imports
header = "Text,Location,Time"
data = header + "\n"
rows_iterated = 0
rows_saved = 0

# Iterate through rows of the DB
while all_items.has_next?
  if rows_saved >= rows then break end

  item =  all_items.next()
  if item['coordinates'] && \
  item['coordinates']['coordinates'] && \
  item['coordinates']['coordinates'][1] && \
  item['coordinates']['coordinates'][0]

    # Add 9 to rows to avoid the division of 10 resulting in 0.
    if rows_saved % ((rows+9)/10) == 0
      puts "Retrieving and formatting rows " + rows_saved.to_s + "-" + (rows_saved+(rows/10)).to_s + "...\n"
    end
    correct_coordinates = [item['coordinates']['coordinates'][1], item['coordinates']['coordinates'][0]]
    text = item['text'].to_s

    # Format the row to an acceptable CSV format. Don't mess with this!
    formatted_row = "\"" + text.gsub(/"/,'""') + "\",\"" + correct_coordinates.to_s.gsub(/\[|\]/, '') + "\",\"" + item['created_at'].to_s + "\""
    data += formatted_row + "\n"
    rows_saved += 1
  else
    # Continue to iterate through the rows but don't increase the count.
  end
  rows_iterated += 1
end

puts rows_saved.to_s + " retrieved out of " + rows_iterated.to_s + " (" + (rows_iterated-rows_saved).to_s + " rows did not have location data). " + ((rows_saved.to_f/rows_iterated.to_f)*100.0).round(2).to_s + "% frequency."

puts "Saving rows to file for streaming to Google Fusion Tables..."

tempfile = 'tempdata.txt'

File.open(tempfile, 'w') do |file|
  file.write(data)
end

# Automatically refresh our access token to make sure we can still access the API
refresh_token = '1/ga2K70JQLsJrL5aFNhzFzo2kGLa9oOOJEQj6stgfN_M' #Needs to be obtained first.
new_access_token = GoogleOAuth::refresh_token(refresh_token)

puts 'Sending data to Fusion Tables...'
table_id = '1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w'
response = send_data_to_fusion(tempfile, new_access_token, table_id, refresh_token)

case response
  when nil
    puts "Could not open data file."
  when Net::HTTPSuccess, Net::HTTPRedirection
    puts "Data post was successful."
  else
    puts "Data post failed."
end

puts "Here is the response from Google:\n"
puts response.body

