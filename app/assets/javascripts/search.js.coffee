namespace "replay.search", (exports) ->

	# Initialize ajax search
	init_search = ->
		search_form = $('#search')
		search_result = $('#search-result')
		q = $('#q')

		# run search on submitting form
		search_form.submit -> search(search_form, false)

		# run search on [space]
		q.keypress((event) -> 
				clearTimeout(exports.search_timeout) if exports.search_timeout?
				if event.which == 32
					search(search_form, true)
				else
					exports.search_timeout = setTimeout((-> search(search_form, true)), 500)
			)

	# search
	searching = false
	search = (form, return_value) ->
		# only run one simultaneous search
		return return_value if searching
		searching = true

		search_result = $("#search-result")
		search_result.trigger('searching')

		# append loading message
		loading = $('<li />', class : 'loading')
		set_load_message = setTimeout((-> search_result.prepend(loading)), 350)

		# variables
		url = form.attr('action')
		query = form.find('#q').val()

		# send query
		$.get(url, q: query, handle_search_result, 'text')
			# clear loading message
			.complete(-> clearTimeout(set_load_message) if set_load_message?)
			# unlock search
			.complete(-> searching = false)
		return return_value

	# display search result
	handle_search_result = (data) ->  
		search_result = $("#search-result")
		q = $('#q')

		# load search results
		search_result.html(data)
		search_result.trigger('searched')

	# initialize this module
	exports.init = ->
		init_search()

# $(document).ready()
$ -> replay.search.init()
