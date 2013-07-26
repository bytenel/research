#!/usr/bin/env ruby
require 'rubygems' # Helps find gems like mongo that aren't in the load path for some reason.
require 'uri'
require 'net/http'
require 'net/https'
require 'mongo' # Allows us to connect to mongo
require 'logger' # Allows file logging
require 'json'

include Mongo

=begin

Tasks:
  -Write full OAuth code for automatic Google API authorization (currently needs to be done manually)
  -Write code to handle errors that may occur with various calls to Google.
  -Evaluate the security of having the client secret in this code
  -Daemonize the script such that it runs once a day at 3am.

=end
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


@client = MongoClient.new('localhost', 27017)
@db     = @client['undergrad_research']
@coll   = @db['tweets']
num_rows = rows
skip_num = skip
puts "Preparing to retrieve the last " + num_rows.to_s + " rows from database after skipping the very last " + skip_num.to_s + " rows.\n\n"
@items = @coll.find({text: { '$exists' => true }, coordinates: { '$exists' => true }, created_at: { '$exists' => true } }, {:fields => ["text", "coordinates", "created_at"], :sort => ["_id", Mongo::DESCENDING], :skip => skip_num})
count = 1
header = "Text,Location,Time"
data = header + "\n"

# Iterate through rows of the DB
while @items.has_next?
  if count >= num_rows
    break
  end
  if count % (num_rows/10) == 0
    puts "Retrieving and formatting rows " + count.to_s + "-" + (count+(num_rows/10)).to_s + "...\n"
  end

  @item =  @items.next()
  correct_coordinates = [@item['coordinates']['coordinates'][1], @item['coordinates']['coordinates'][0]]
  text = @item['text'].to_s
  row = "\"" + text.gsub(/"/,'""') + "\",\"" + correct_coordinates.to_s.gsub(/\[|\]/, '') + "\",\"" + @item['created_at'].to_s + "\""
  data += row + "\n"

  count += 1
end

File.open("tempdata.txt", 'w') do |file|
  file.write(data)
end


# This code will automatically refresh our access token to make sure we can still access the API

google_oauth = URI.parse('https://accounts.google.com/o/oauth2/token')
client_id = '524332453800-b31p35fpq4chitlbfp4aol3cfda4bv7e.apps.googleusercontent.com'
client_secret = '0Os0EqKH36aHQuAdCDxvPmML'
refresh_token = '1/HMfIVUwemOGr1ktPNCqgAK8LW4WVVoMNixIDUiy55Ow' #Needs to be obtained first.

# Create the HTTP object
https = Net::HTTP.new(google_oauth.host, google_oauth.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.set_debug_output(Logger.new("http.log"))

puts 'Asking Google to refresh our access token...'
response = https.post(google_oauth.path, 'client_id=' + client_id + '&client_secret=' + client_secret + '&refresh_token=' + refresh_token + '&grant_type=refresh_token')

puts 'Parsing response from Google for access token...'
# Get the access token from the response.
access_token = JSON.parse(response.body)['access_token'];


puts 'Preparing data to be sent to Fusion Tables...'

uri = URI.parse('https://www.googleapis.com/upload/fusiontables/v1/tables/1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w/import')

headers = {"Authorization" => 'Bearer ' + access_token, "Content-Type" => 'application/octet-stream', "Content-Length" => data.length, "Transfer-Encoding" => "chunked"}

# Create the HTTP object
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.set_debug_output(Logger.new("http.log"))
# puts 'Sending data...'
# response = https.post(uri.path, data, headers)

# New import tactic: stream the data from a file to avoid  memory issues.
req = Net::HTTP::Post.new(uri.path)
req['Authorization'] = 'Bearer ' + access_token
req['Content-Type'] = 'application/octet-stream'
req['Content-Length'] = data.length
req['Transfer-Encoding'] = 'chunked'
File.open("tempdata.txt", 'r') do |file|
  req.body_stream=file
  puts 'Sending data...'
  response = https.request(req)
end

# Clean up temporary file afterwards
File.delete("tempdata.txt")

#Debugging output code:
puts "Here is the response from Google:\n"
puts response.body

case response
when Net::HTTPSuccess, Net::HTTPRedirection
	puts "Data post was successful."
else
	puts "Data post failed."
end
