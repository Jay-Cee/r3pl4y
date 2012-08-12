class SearchController < ApplicationController
	def index
		@search_result = []
		q = params['q']

		# get all words, longer than 2
		words = q.downcase.split(' ').find_all{|item| item.length > 2}

		if q and not words.empty?
			sql = "SELECT * FROM games INNER JOIN ("
			sql += "SELECT gw.game_id"

			for i in 1..words.length do
				sql += ", max(w#{i}.id) as word#{i}"
			end

			sql += " FROM game_words gw "

			# join for every word
			for i in 1..words.length do
				sql += "LEFT JOIN words w#{i} ON w#{i}.id = gw.word_id AND w#{i}.word = ? "
			end

			sql += "WHERE "

			# filter those not matching
			for i in 1..words.length do
				sql += "w#{i}.word = ? "
				sql += "OR " unless i == words.length # last
			end

			sql += "GROUP BY gw.game_id ORDER BY "

			# fix ordering
			for i in 1..words.length do
				sql += "word#{i}"
				sql += ", " unless i == words.length # last
			end

			sql += " LIMIT 20)"
			sql += " AS words ON id = words.game_id"
			sql += " WHERE is_public = true"

			query = [sql] + (words * 2)

			@search_result = Game.find_by_sql query
		end

		respond_to do |format|
			format.html  # index.html.erb
			format.text { render :layout => false }
		end
	end
	
end
