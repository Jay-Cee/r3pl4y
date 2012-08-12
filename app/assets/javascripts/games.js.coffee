namespace "replay.games", (exports) ->

	# Initialize this namespace
	exports.init = ->
		return unless $(document.body).hasClass('games')

		# list is preloaded from code behind
		# to fix time in list, we trigger the updated event
		# delayed start, because events need to be hooked up first
		setTimeout((-> $('#game-reviews').trigger('updated')), 50)

		# click on li element should redirect browser to a.review-link
		$(document.body).on('click', '.has-review', -> document.location.href = $(this).find('a.review-link').attr('href'))		

# $(document).ready() 
$ -> replay.games.init();
