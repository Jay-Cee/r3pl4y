class ScoreObserver < ActiveRecord::Observer
	observe Review

	# add score to user
	def after_save(review)
		# rating
		review.user.score += review.rating? ? 1 : 0

		# review
		review.user.score += review.review? ? 5 : 0

		# save
		review.user.save
	end

  # decrease score before destroy
  def before_destroy(review)
    # rating
    review.user.score -= review.rating? ? 1 : 0;

    # review
    review.user.score -= review.review? ? 5 : 0;

    # save
    review.user.save
  end
end
