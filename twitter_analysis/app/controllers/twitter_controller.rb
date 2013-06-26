class TwitterController < ActionController::Base
	layout 'application'

	#need to define index to be the baseline method and then define another to change the number of tweets displayed
	def index
		count = params[:count]
		#respond to json requests with tweets
		@tweets = Tweet.all.to_a[1]
		@tweets

		# use this for responding to different request formats TODO
		#respond_to do |format|  
	    #  if @post.save  
	    #    format.html { redirect_to(@post, :notice => 'Post created.') }  
	    #j    format.js  
	    #  else  
	    #    format.html { render :action => "new" }  
	    #    format.js  
	    #  end  
	    #end 

	    respond_to do |format|
			format.json { render :json => @tweets.to_json }
			format.html { render }
	    end
	    #USE THIS TO RETURN JSON tweets TO AJAX REQUESTS
	    #respond_with
  end
  def map

  end
end
