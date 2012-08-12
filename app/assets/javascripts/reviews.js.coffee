namespace "replay.reviews", (exports) ->
	MAX_REVIEW_LENGTH = 150

	shorten = (reviews) ->
		reviews.each ->
			long = $(this)
			long.removeClass('shorten')

			# create short version
			short = $("<div />", class: "review-body-short")

			total = 0
			long.find('p').each ->
				paragraph = $(this).clone()
				length = paragraph.text().length

				# need to cut this element
				cut(paragraph, MAX_REVIEW_LENGTH - total) if MAX_REVIEW_LENGTH > total and MAX_REVIEW_LENGTH < (total + length)

				# add complete paragraph to short version
				short.append(paragraph) if total < MAX_REVIEW_LENGTH

				total += length

			# hide long version
			long.hide()
			# append short version
			long.after(short)

	# cut a paragraph, end it with read more link
	cut = (paragraph, length) ->
		# cut the paragraph at desired length
		paragraph.text( paragraph.text().substr(0, length) )

		# create read more link element
		a = $("<a />", class: 'read-more', href: '#').html('&hellip; read more')

		# attach event handler to click event
		a.click(display_long)

		# append link to paragraph
		paragraph.append(a)
	
	# event handler will hide short version, and display long version of article body
	display_long = ->
		# find article element
		article = $(this).parent().parent().parent()

		# find long body element and display it
		article.find('.review-body').show()

		# hide short body element
		article.find('.review-body-short').hide()

		# don't follow link
		return false

	# prepend the list with new items
	prepend_list = (list) ->
		# don't load if already loading
		first = list.children(":first")
		return if first.hasClass('loading')

		# trigger updating
		list.trigger('updating')

		# get url from data-source attribute
		url = list.attr('data-source')

		# append loading message after 500ms of waiting
		loading = $('<li />', class : 'loading')
		set_load_message = setTimeout((->	list.prepend(loading)), 350)

		# get limiter
		to = first.find('.published').attr('datetime') if first.length == 1

		# go get list data
		$.get(url, to : to, ((data) ->
			# clear loading message
			clearTimeout(set_load_message) if set_load_message?
			loading.remove()
			# update list 
			list.prepend(data) and list.trigger('updated')))

	# append new items to list
	append_list = (list) ->
		# don't load if already loading
		last = list.children(":last")
		return if last.hasClass("loading") or last.hasClass("end")

		# trigger updating
		list.trigger('updating')

		# get url from data-source attribute
		url = list.attr('data-source')

		# append loading message
		loading = $('<li />', class : 'loading')
		set_load_message = setTimeout((-> list.append(loading)), 350)

		# get limiter
		from = last.attr('data-from') if last.length == 1

		# go get list data
		$.get(url, from : from, ((data) ->
		  # clear loading message
			clearTimeout(set_load_message) if set_load_message?
			loading.remove()
			# update list 
			list.append(data) and list.trigger('updated')
			# add end of stream message, if result was empty
			list.append($('<li />', class : 'end').text('No more reviews for you')) if $(data).length == 0))

	# exporting functions
	exports.prepend_list = prepend_list
	exports.append_list = append_list

	exports.init = ->
		# make sure time elements are localized on updated list
		$(document.body).on('updated', '.review-list, .game-list, .user-list', -> replay.utils.localize_time($(this).find('time')))

		# shorten articles marked shorten
		$(document.body).on('updated', '.review-list, .game-list, .user-list', -> shorten($(this).find('.shorten')))

		# trigger append when click on load-more-link
		$(document.body).on('click', '.load-more-link', -> append_list($(this).parent().parent()) and false)

		# on updating, remove load-link
		$(document.body).on('updating', '.review-list, .game-list, .user-list', -> $(this).find('.load-more').remove())

# $(document).ready()
$ -> replay.reviews.init()
