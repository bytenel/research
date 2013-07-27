# This script allows a user to train the Prediction API by manually labeling our tweets and sending them off to Google

require 'rubygems' # Helps find gems like mongo that aren't in the load path for some reason.
require 'mongo' # Allows us to connect to mongo
require_relative 'google_oauth'


# TODO: Load in unique tweets from mongo one at a time

# TODO: Present user option to rate (regression/numerical) the tweet on sentiment, or to discard from sample

# TODO: When user is done training or when the amount of data nears 2MB, send the training data off to the Prediction API.