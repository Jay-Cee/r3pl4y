namespace "replay.global", (exports) ->

# Hide components that should be invisible with javascript
# Show components that should be visisble with javascript
  script_hide_show = ->
    $('.script-hide').hide();
    $('.script-show').show();

# make js media queries aware
  js_media_queries = ->
    width = document.documentElement.clientWidth
    addClass = 'phone' if width  < 768
    addClass = 'portrait' if width >= 768 and width < 1024
    addClass = 'landscape' if width >= 1024 and width < 1440
    addClass = 'desktop' if width >= 1440
    $(document.body).removeClass('phone portrait landscape desktop').addClass(addClass)

  # destroy a balloon
  destroy_balloon = ->
    el = $(this)
    # recreate title element
    el.attr('title', el.data('title'))
    # remove balloon
    el.data('balloon').remove()

  # create a balloon
  create_balloon = ->
    el = $(this)
    title = el.attr('title')
    return if title == "" # quick escape

    # remove title, move it into property bag
    el.data('title', title)
    el.removeAttr('title')

    # create balloon
    balloon = $('<span />', class: 'balloon', text: title).appendTo('body')
    el.data('balloon', balloon)

    # calculate position
    x = (el.offset().left + (el.width() / 2)) - (balloon.width() / 2)
    y = el.offset().top - balloon.height() - 20

		# position balloon
    balloon.css('top', "#{y}px").css('left', "#{x}px")

    # bind mouseout to destroy
    el.mouseout(destroy_balloon)
    el.click(destroy_balloon)


  # Create a balloon out of title attributes on img, a, span
  balloon = -> $(document.body).on('mouseover', 'img[title],a[title],span[title]', create_balloon)

  # A hack to fix label click in mobile safari
  fix_label_click = -> $('label.rating').click ->

	# Initialize this module
  exports.init = ->
    script_hide_show()
    balloon()
    fix_label_click()

    # set js media query class on body
    js_media_queries()
    $(window).on('throttledresize', js_media_queries)

# $(document).ready()
$ -> replay.global.init()
