class SearchIndexObserver < ActiveRecord::Observer
	observe Game

	# add search index words to game
	def before_save(game)
		# debug
		puts "SearchIndexObserver: Create words for #{game.title}"

		# slugify the title
		slug = Game.create_slug(game.title)

		# get all words > 2 in length
		words = slug.split('-').find_all {|item| item.length > 2}

		words.each do |word|
			index = Word.find_by_word(word)

			if index
				game.words.push(index)
			else
				game.words.push(Word.create! :word => word)
			end
		end
	end
end
