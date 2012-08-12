namespace "replay.utils", (exports) ->

	format =
		# These might have to be globalized in the future
		weekdays : ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],

		# These might have to be globalized in the future
		months : [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ],

		# get hours from date with leading zero
		getHours : ((date) ->	if date.getHours() < 10 then "0#{date.getHours()}" else "#{date.getHours()}"),

		# get minutes from date with leading zero
		getMinutes : ((date) -> if date.getMinutes() < 10 then "0#{date.getMinutes()}" else "#{date.getMinutes()}"),

	# parse string '2012-05-05T16:16:34Z' to datetime
	parse_datetime = (str) ->
		exp = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/
		date = new Date()
		parts = exp.exec(str)

		# not correct format
		throw "Failed to parse as time: #{str}" unless parts

		month = +parts[2]
		date.setUTCFullYear(parts[1], month - 1, parts[3])
		date.setUTCHours(parts[4], parts[5], parts[6])
		return date

	# will parse through all time elements and pretty print them
	localize_time = (elements) ->
		for el in elements
			time = $(el)
			link = time.find('a:first-child')
			cont = if link.length == 1 then link else time

			published = parse_datetime(time.attr('datetime'))
			now = new Date()

			# seconds difference between now and published
			timespan = (now.getTime() / 1000) - (published.getTime() / 1000)

			# If less than 60 seconds, say 'Now'
			if timespan < 60
				cont.text('Now')

			# If less than 60 minutes, say 'dd minutes ago'
			else if timespan < 3600
				cont.text("#{Math.round(timespan / 60)} minutes ago")

			# If less than 12 hours, say 'hh hours ago'
			else if timespan < 12 * 3600
				cont.text("#{Math.round(timespan / 3600)} hours ago")

			# If less than 24 hours and same day, say 'Today 12:34'
			else if (timespan < 24 * 3600) and now.getDate() == published.getDate()
				cont.text("Today #{format.getHours(published)}:#{format.getMinutes(published)}")

			# If less than 48 hours and yesterday, say 'Yesterday 12:34'
			else if (timespan < 48 * 60 * 60) and (now.getDate() - 1) == published.getDate()
				cont.text("Yesterday #{format.getHours(published)}:#{format.getMinutes(published)}")

			# If less than 7 days, say 'Sunday 12:34'
			else if timespan < 7 * 24 * 60 * 60
				cont.text("#{format.weekdays[published.getDay()]} #{format.getHours(published)}:#{format.getMinutes(published)}")

			# Else say '18 January, 12:34'
			else
				cont.text("#{published.getDate()} #{format.months[published.getMonth()]} #{published.getFullYear()}, #{format.getHours(published)}:#{format.getMinutes(published)}")

	# fill element with contents from data-source attribute
	load_source = (el) ->
		# trigger loading event
		el.trigger('loading')

		# remove error class from previous attempts
		el.removeClass('error')

		# get url from data-source attribute
		source = el.data('source')

		# append loading message after 350 ms of waiting
		set_load_message = setTimeout((->
			el.trigger('waiting')
			el.addClass('loading')), 350)

		# get data
		$.get(source, ((data) -> el.html(data)), 'text')
			# trigger load-success on success
			.success(-> el.trigger('load-success'))

			# trigger loaded on complete
			.complete(-> el.trigger('loaded'))

			.complete(->
				# clear load message
				clearTimeout(set_load_message) if set_load_message?
				el.removeClass('loading'))

			# trigger load-fail on failure
			.fail(-> el.trigger('load-fail'))

			# display error
			.fail(-> el.addClass('error'))



	# exporting functions
	exports.localize_time = localize_time
	exports.load_source = load_source
