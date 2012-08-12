namespace "replay.users", (exports) ->
	exports.init = ->
		return unless $(document.body).hasClass('users')

		# list is preloaded from code behind
		# to fix time in list, we trigger the updated event
		# delayed start, to ensure that events has been hooked up

		setTimeout((-> $('#latest-reviews').trigger('updated')), 50)
	
		# click on li element should redirect browser to a.review-link
		$(document.body).on('click', '.has-review', -> document.location.href = $(this).find('a.review-link').attr('href'))

# $(document).ready()
$ -> replay.users.init()
