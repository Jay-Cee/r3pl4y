class ShareToFacebookObserver < ActiveRecord::Observer
	observe Review
	
	# share review to facebook
	def after_create(review)
		return unless review.share_facebook == "true"
    review.delay.share_to_facebook!
	end

end
