# This script allows a user to train the Prediction API by manually labeling our tweets and sending them off to Google

require 'rubygems' # Helps find gems like mongo that aren't in the load path for some reason.
require 'mongo' # Allows us to connect to mongo
require_relative 'google_oauth'

include Mongo

# TODO: Create a module to handle all the functions and variables for this program.
module PredictionAPIUtil

  @@training_data_filename = 'training_data_temp.txt'
  @@format_before_tweet = '{ "csvInstance" : ["'
  @@format_before_rating = '"], "output" : "'
  @@format_after_rating = '" }, '

  # Retrieves a single tweet from the database at a specified index.
  def getTweet(index)
    @client = MongoClient.new('localhost', 27017)
    @db     = @client['undergrad_research']
    @coll   = @db['tweets']
    items = @coll.find({}, {limit:1, skip:index})
  end


  # Saves the grade given to a tweet (if any given), and returns a boolean determining whether to continue training or not.
  def processInput(tweet, input)
    if input == 'done' then return false end
    if input == 'skip' then return true end
    grade = input.to_i
    if grade < 1 || grade > 10
      puts "You must enter a number between 1 and 10. Moving to next tweet."
      return true
    else
      File.open(@@training_data_filename, 'a') do |file|
         file.write(@@format_before_tweet + tweet + @@format_before_rating + grade + @@format_after_rating)
      end
    end

  end


  def sendData()
    puts "Requesting code from Google..."
    GoogleOAuth::request_code(GoogleOAuth::Scopes::PREDICTION_SCOPE)
    puts "Please view the authentication dialog in your browser to authenticate the application."
    puts "Paste the code provided here: "

    code = gets.chomp
    response_data = GoogleOAuth::request_token(code)
    access_token = response_data['access_token']

    project_id = '77847676586'
    api_key = 'AIzaSyA1IZ9bdgdN4zgDJ8gxRxMh0WAnz81J-0w' # This needs to be kept secret
    model_id = 'test'
    model_type = 'REGRESSION'
    #request_object = {id: model_id, modelType: model_type, trainingInstances: training_instances}

    File.open(@@training_data_filename, 'a') do |file|
      file.write('], "id": "' + model_id + '", "modelType": "' + model_type + '" }') # Finish up the json file.
    end

    # Create the HTTP object
    uri = URI.parse('https://www.googleapis.com/prediction/v1.6/projects/' + project_id + '/trainedmodels?key=' + api_key)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.set_debug_output(Logger.new("http.log"))

    # Stream the data from a file to avoid memory issues.
    req = Net::HTTP::Post.new(uri.path)
    req['Authorization'] = 'Bearer ' + access_token
    req['Content-Type'] = 'application/json'
    req['Content-Length'] = File.size(@@training_data_filename)
    req['Transfer-Encoding'] = 'chunked'
    response = nil;
    File.open(@@training_data_filename, 'r') do |file|
      req.body_stream=file
      response = https.request(req)
    end

    # Clean up temporary file afterwards
    File.delete("tempdata.txt")

    return response

  end

end

puts "Okay, here's how this works.\n\rYou will be presented with a text status of a random tweet. After reading the tweet, you must give it a rating of 1-10." +
         "1 represents discontent, anger, disapproval, and disinterest - but NOT sadness. 10 represents approval, excitement, interest, and contentedness. " +
         "5 represents an indifference, or lack of emotion. If the tweet is too short to evaluate, or in an unrecognizable language, simply enter 'skip'."
puts "Got it? Here we go:\r\n"


# TODO: Present user option to rate (regression/numerical) the tweet on sentiment, or to discard from sample
current = 0

File.open(@@training_data_filename, 'w') do |file|
  file.write('{ "trainingInstances": [')
end

begin
  item = getTweet(current).next()
  current += 1
  if (item.empty?)
    puts "Sorry, there are no more tweets."
    puts item.to_s
    break
  end

  # If there is no 'text' attribute, the tweet is malformed, so move to the next one
  if (!item['text'])
    next
  end
  puts "Tweet: " + current.to_s + item['text']
  input = gets.chomp
  # TODO: Impose a 2MB limit on training data
end while (processInput(item['text'], input))

sendData()

