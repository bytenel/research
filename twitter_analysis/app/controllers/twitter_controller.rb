class TwitterController < ActionController::Base
	def index
		#respond to json requests with tweets
		@tweets = Tweet.all.to_a.pop
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

	    #USE THIS TO RETURN JSON tweets TO AJAX REQUESTS
	    #respond_with
	end
end
