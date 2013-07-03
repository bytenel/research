#!/usr/bin/env ruby
require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'mongo'
require 'logger'

include Mongo

=begin

Tasks:
  -Write full OAuth code for automatic Google API authorization (currently needs to be done manually)
  -Daemonize the script such that it runs once a day at 3am.

=end

@client = MongoClient.new('localhost', 27017)
@db     = @client['undergrad_research']
@coll   = @db['tweets']
num_rows = 100
puts "Preparing to retrieve the first " + num_rows.to_s + " rows from database.\n\n"
@items = @coll.find({text: { '$exists' => true }, coordinates: { '$exists' => true }, created_at: { '$exists' => true } }, {:fields => ["text", "coordinates", "created_at"]})
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

# This code will automatically refresh our access token to make sure we can still access the API
=begin
google_oauth = URI.parse('https://accounts.google.com/o/oauth2/token')
client_id = '524332453800-b31p35fpq4chitlbfp4aol3cfda4bv7e.apps.googleusercontent.com'
client_secret = '0Os0EqKH36aHQuAdCDxvPmML'
refresh_token = '' #Needs to be obtained first.

# Create the HTTP object
https = Net::HTTP.new(google_oauth.host, google_oauth.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.set_debug_output(Logger.new("http.log"))
response = https.post(google_oauth.path, 'client_id=' + client_id + '&client_secret=' + client_secret + '&refresh_token=' + refresh_token + '&grant_type=refresh_token')

puts response.body
=end

puts 'Preparing data to be sent to Fusion Tables...'

auth_code = 'ya29.AHES6ZS5GO8Nl1aNU6UObd5vFcMm7ODkeDdn8tmlbboVqNA' #This needs to be obtained, not saved

uri = URI.parse('https://www.googleapis.com/upload/fusiontables/v1/tables/1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w/import')

headers = {"Authorization" => 'Bearer ' + auth_code, "Content-Type" => 'application/octet-stream'}

# Create the HTTP object
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.set_debug_output(Logger.new("http.log"))
puts 'Sending data...'
response = https.post(uri.path, data, headers)

#Debugging output code:
puts "Here is the response from Google:\n"
puts response.body

case response
when Net::HTTPSuccess, Net::HTTPRedirection
	puts "Data post was successful."
else
	puts "Data post failed."
end
