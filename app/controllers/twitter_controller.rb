class TwitterController < ActionController::Base
	layout 'application'

	def index
	count = params[:count]
    @tweets = Tweet.all.to_a.last(40)

	 respond_to do |format|
		format.json { render :json => @tweets.to_json }
		format.html { render }
	 end
  end
 
  def map

  end

  def search
  	#add in mike's search functionality code
  end
end
