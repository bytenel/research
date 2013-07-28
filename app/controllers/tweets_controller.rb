class TweetsController < ActionController::Base
  def index
    @tweets = Tweet
  end
end