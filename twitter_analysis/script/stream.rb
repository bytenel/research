#should stream everything correctly
require 'tweetstream'
require 'open-uri'
require 'mongo'
require 'json'

db = Mongo::Connection.new("localhost",27017).db("undergrad_research")
tweets = db.collection("tweets")

TweetStream.configure do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.oauth_token = ENV['TWITTER_OATH_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_OATH_TOKEN_SECRET']
    config.auth_method = :oauth
end

    DESIRED = %w{created_at text coordinates user entities id id_str}

puts "Beginning stream..."
     begin
       TweetStream::Daemon.new('tweetstream').on_error do |message|
		puts "An error occurred...#{message}"
	        exit(1) 
		#from alaska to florida 
	   end.locations('-170.00','12.00','-70.00','55.00',nil) do |status, client|
		  data = status.attrs.select{|k,v| !v.nil? && DESIRED.include?(k.to_s)}
		  tweets.insert(data)
		  puts data.to_s
	end
	rescue Interrupt
			puts "Closing connection..."
			exit(0)
     end
