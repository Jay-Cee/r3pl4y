class ShareToTwitterObserver < ActiveRecord::Observer
	observe Review
	include ActionView::Helpers::UrlHelper


	# share review to twitter
	def after_create(review)
		return unless review.share_twitter == "true"
    review.delay.share_to_twitter!
	end
end
