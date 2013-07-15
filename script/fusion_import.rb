#!/usr/bin/env ruby
require 'mongo'

=begin

  -Be able to retrieve data from mongo in CSV format. Start with 100 rows at a time.
  -Line up this data with the code below to send it off to Fusion Tables
  -Daemonize the script such that it runs once a day at 3am.

=end


# This is the full code for importing CSV data into Fusion Tables via the API.
=begin

#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'net/https'

# Table ID: 1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w

# If we need to pull the data from a file:
data=''

File.open("sample.txt") do |file|
	data = file.read
end

uri = URI.parse('https://www.googleapis.com/upload/fusiontables/v1/tables/1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w/import')

headers = {"Authorization" => 'Bearer ya29.AHES6ZTbvlsLiQCvAQ4gXjJ7iDxr0PdyP1yYA62bt0SLUGc', "Content-Type" => 'application/octet-stream'}

# Create the HTTP object
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
# USE FOR DEBUGGING: https.set_debug_output $stderr
response = https.post(uri.path, data, headers)


#Debugging output code:

puts response.body
case response
when Net::HTTPSuccess, Net::HTTPRedirection
	puts "SUCCESS"
else
	puts "FAILURE"
end


==================================================end