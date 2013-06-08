class TwitterController < ActionController::Base
	def index
		#respond to json requests with tweets
		@tweets = Tweet.all.to_a
		@tweets
	end
end
