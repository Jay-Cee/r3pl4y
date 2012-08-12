class AggregateRatingObserver < ActiveRecord::Observer
	observe Review

	# aggregate rating after review
	def after_save(review)
		game_id = review.game_id

		ActiveRecord::Base.connection.execute "UPDATE games SET rate_average = COALESCE((SELECT AVG(rating) FROM reviews WHERE game_id = #{game_id}), 0), rate_quantity = (SELECT COUNT(id) FROM reviews WHERE game_id = #{game_id} AND rating IS NOT null) WHERE id = #{game_id}"
	end
end
