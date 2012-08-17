namespace "replay.profile", (exports) ->

  # navigation class
  class Navigation
    constructor: (@body) ->
      links = '.game-link,.review-link,.user-link,.list-link,.following-link,.followers-link'

      @body.on('click', '.has-review', @click_review_link_cb)
      $('body:not(.phone)').on('click', links, @load_view_cb)

      # notify body there're three columns
      @body.on('click', '.game-link,.review-link,.user-link,.list-link', @set_three_columns_cb)
      @body.on('loading', '.right', @set_three_columns_cb)

      # post processing of loaded panes
      @body.on('loaded', '.right', @append_review_list_cb)
      @body.on('loaded', '.right', @append_game_list_cb)
      @body.on('loaded', '.right', @append_user_list_cb)
      @body.on('loaded', '.right', @append_duplicates_list_cb)
      @body.on('loaded', '.right', @localize_time_cb)

      # pop state
      window.onpopstate = @pop_state_cb if Modernizr.history

    # find review-link and click it
    click_review_link_cb : (e) => @click_review_link($(e.currentTarget))
    click_review_link : (el) -> el.find('a.review-link').click()

    # load dynamic views
    load_view_cb : (e) =>
      e.stopPropagation()
      link = $(e.currentTarget)
      @load_view(link.attr('href'), link.parents('section'))

    load_view : (href, current) ->
      # previous section
      previous = current.prev('section')

      # remove animation classes
      previous.removeClass('animate-minimize-left animate-maximize-left')

      # don't duplicate a view
      return false if current.data('source') == href

      # create right section
      right = $("<section class='right' data-source='#{href}' />")

      # append right element
      appended = 0
      append_right = ->
        return if appended++

        # remove all sections after this section
        current.nextAll('section').remove()

        # hide previous
        previous.addClass('animate-minimize-left hidden') unless previous.hasClass('menu-wrapper')

        # make this middle column
        current.addClass('middle')
        current.removeClass('right')

        # place right after current
        current.after(right)

      right.on('load-success', @push_state_cb) if Modernizr.history
      right.on('load-success', append_right)
      right.on('waiting', append_right)

      # load section with data
      replay.utils.load_source(right) and false

    # change the url
    push_state_cb : (e) => @push_state($(e.currentTarget))
    push_state : (view) -> history.pushState({source : view.data('source')}, '', view.data('source'))

    # recover a state
    pop_state_cb : (e) => @pop_state(e.state)
    pop_state : (state) ->
      return unless state?
      current = $("section[data-source='#{state.source}']")

      if current.length > 0 # going backwards in history
        # remove everything after this
        current.nextAll('section').remove()
        current.addClass('right')
        current.removeClass('middle hidden')

        # previous should be unhidden
        previous = current.prev('section')
        previous.removeClass('hidden animate-minimize-left animate-maximize-left').addClass('animate-maximize-left')

      else # going forwards in history
        @load_view(state.source, @body.find('section:last'))

    # make dynamic lists load themselves
    append_review_list_cb : (e) => @append_list($(e.currentTarget), '.review-list')
    append_game_list_cb : (e) => @append_list($(e.currentTarget), '.game-list')
    append_user_list_cb : (e) => @append_list($(e.currentTarget), '.user-list')
    append_duplicates_list_cb : (e) => @append_list($(e.currentTarget), '.duplicates-list')
    append_list : (section, selector) ->
      replay.reviews.append_list(section.find(selector))

    # localize published
    localize_time_cb : (e) => @localize_time($(e.currentTarget))
    localize_time : (section) ->
      replay.utils.localize_time(section.find('time.published'))

    # notify body there're three columns now
    set_three_columns_cb : (e) => @set_three_columns()
    set_three_columns : ->
      # tell body there's three columns now
      @body.removeClass('two-columns')
      @body.addClass('three-columns')

  # menu class
  class Menu
    constructor: (@body, @menu) ->
      @middlec = @body.find('#static-content')
      @timeline = @body.find('#timeline')

      @menu.on('click', 'a:not(.logout)', @load_menu_item_cb)
      @menu.on('click', 'a.timeline', @prepend_timeline_cb)
      @menu.on('click', 'a.following', @load_source_cb)
      @menu.on('click', 'a.followers', @load_source_cb)
      @menu.on('click', 'a.stats', @load_source_cb)

      # set body class two-columns
      @menu.on('click', 'a:not(.logout)', @set_two_columns_cb)

    # load the corrent menu item
    load_menu_item_cb : (e) => @load_menu_item($(e.currentTarget))
    load_menu_item : (menu_item) ->
      # remove all right columns
      @middlec.nextAll("section").remove()

      # display middlec again
      @middlec.removeClass('hidden')

      # content
      id = menu_item.data('container')
      @middlec.children().hide()
      $(id).show()

      # scroll to top
      $(id).scrollTop(0)

      # switch selected
      @menu.find('a').removeClass('selected')
      menu_item.addClass('selected') and false

    # prepend timeline
    prepend_timeline_cb : (e) => @prepend_timeline($(e.currentTarget))
    prepend_timeline : (link) ->
      # prepend any new items to timeline
      replay.reviews.prepend_list(@timeline) and false

    # find container, get source
    load_source_cb : (e) => @load_source($(e.currentTarget))
    load_source : (link) ->
      container = $(link.data('container'))
      replay.utils.load_source(container) and false

    # set two columns
    set_two_columns_cb : (e) => @set_two_columns() and false
    set_two_columns : ->
        # tell body there're two columns now
        @body.addClass('two-columns')
        @body.removeClass('three-columns')

  class Timeline
    constructor : (@timeline) ->
      @timeline.on('scroll', @scroll_loading_cb)

			# load timeline
      setTimeout(@load_cb, 1)

    # load timeline with data
    load_cb : (e) => @load()
    load : -> replay.reviews.append_list(@timeline)

    # trigger loading if loading element is visible while scrolling
    scroll_loading_cb : (e) => @scroll_loading($(e.currentTarget))
    scroll_loading : (timeline) ->
      return if timeline.data('loading') # fail fast
      timeline.data('loading', true)

      # get y position of scroll and last list item
      last = timeline.children(':last')
      scrollBottom = timeline.scrollTop() + $(window).height()
      loadingTop = last.offset().top

      # scroll is past last list item
      if scrollBottom > loadingTop
        # turn off loading after timeline has loaded
        turn_loading_off = ->
          timeline.data('loading', false)
          timeline.off('updated', turn_loading_off)

        timeline.on('updated', turn_loading_off)
        replay.reviews.append_list(timeline)

      # no loading of new items, allow new scrolls
      else
        timeline.data('loading', false)

  class Review
    constructor : (@body) ->
      @enable_legacy_browsers() if $.browser.msie
      @body.on('click', '#new_review .submit', @new_review_cb)
      @body.on('click', '.edit_review .submit', @edit_review_cb)

      # apply lightbox
      @lb_inner_width = 924
      @lb_inner_height = 568
      @lb_initial_width = @lb_inner_width
      @lb_initial_height = @lb_inner_height
      @body.on('loaded', @apply_lightbox_button_cb)
      @body.on('updated', @apply_lightbox_button_cb)

      # hook up delete button
      @body.on('click', '.delete-button', @confirm_delete_cb)

    # initialize markdown editor
    init_markdown_cb : (e) => @init_markdown()
    init_markdown : ->
      converter = Markdown.getSanitizingConverter()
      editor = new Markdown.Editor(converter)
      editor.run()

    # apply lightbox reviewing a game
    apply_lightbox_button_cb : (e) => @apply_lightbox_button($(e.currentTarget))
    apply_lightbox_button : (section) ->
      section.find('.review-button, .edit-button').colorbox(
        innerWidth : @lb_inner_width,
        innerHeight : @lb_inner_height,
        initialWidth : @lb_initial_width,
        initialHeight : @lb_initial_height,
        onComplete : @init_markdown_cb)

    # confirm box
    confirm_delete_cb : (e) =>
      e.stopPropagation()
      @confirm_delete($(e.currentTarget))

    confirm_delete : (link) ->
      return @delete_review(link) if window.confirm(link.data('confirm'))
      return false

    # delete a review
    delete_review : (button) ->
      url = button.attr('href')
      # call delete url by ajax
      $.ajax(
        url: url,
        type: 'DELETE',
        dataType: 'json',
        success: (data) ->
          button.parents('li').remove()
          $("[data-source='#{url}']").remove()
      )
      return false

    # Make sure that review form functions in IE 6-8
    enable_legacy_browsers : ->
      # Selected radio button changes
      @body.on('change', '.new-review input.rating', ->
        # Paint them all black
        $(".new-review label.rating").removeClass('selected')
        # Color the selected radio label
        $(this).next('label').addClass('selected'))

      # Click on finished checkbox
      # Toggle the selected class on star on/off
      @body.on('change', '.new-review input.finished', ->
        $(this).next('label').toggleClass('selected'))

      # Click on share button
      # Toggle activated/deactivated
      @body.on('change', '.new-review input.share', ->
        $(this).next('label').toggleClass('selected'))

    # post review form by ajax
    edit_review_cb : (e) =>
      @new_review(@body.find('form.edit_review'), $(e.currentTarget), 'PUT') and false
    new_review_cb : (e) =>
      @new_review(@body.find('#new_review'), $(e.currentTarget), 'POST') and false

    new_review : (form, submit_button, form_type) ->
      # avoid dubble posting and change button appearance
      submit_button.attr('disabled', 'disabled')
      submit_button.addClass('loading')
      # remove any alert message
      @body.find('.alert').remove()
      # get target url
      url = form.attr('action')
      # post the data
      $.ajax(
        url: url,
        type: form_type,
        dataType: 'json',
        data:
          utf8 : form.find('input[name=utf8]').val(),
          authenticity_token : form.find('input[name=authenticity_token]').val(),

          'review[game_id]' : $("#review_game_id").val(),
          'review[rating]' : $('input.rating:checked').val(),
          'review[review]' : $('#wmd-input').val(),
          'review[finished]' : ($('#review_finished').is(':checked') ? '1' : '0'),
          'review[share_facebook]' : ($('#review_share_facebook').is(':checked') ? '1' : '0'),
          'review[share_twitter]' : ($('#review_share_twitter').is(':checked') ? '1' : '0'))

        .success(->
          $.colorbox.close()
          $(document.body).trigger('new-review'))
        .error(->
          form.before($('<p />', class : 'alert').text('Failed to submit review')))
        .complete(->
          submit_button.removeAttr('disabled')
          submit_button.removeClass('loading'))

  class Profile
    constructor : (@body) ->
      @tumblr_error_msg = $('<p />', class : 'alert').text('Failed to load last blogpost from <a href="http://blog.r3pl4y.com">http://blog.r3pl4y.com</a>')

      # bind li click to inner link
      @body.on('click', '.game-list li', -> $(this).find('a.game-link').click())
      @body.on('click', '.user-list li', -> $(this).find('a.user-link').click())
      @body.on('click', '.custom-lists li', -> $(this).find('a.list-link').click())

      # show start on menu header click
      @body.on('click', '.menu header', @reset_cb)
      @body.on('click', '.menu header', @start_cb)

      # unselect menu items on search input focus
      @body.on('focus', '#q', @unselect_cb)

      # make whole search field visible on #q:focus
      @body.on('focus', '#q', @search_focus_cb)

      # bind click on follow link
      @body.on('click', '.follow-link', @follow_toggle_cb)

      # copy invite-link to clipboard
      @body.on('click', '.invite-link', @copy_clipboard_cb)

      # display search result pane on searching
      @body.on('searching', '#search-result', @searching_cb)

      # open start on collapse-link click
      @body.on('click', '.collapse-link', @display_start_cb)

      # hide scrollbar in middle column
      $('#timeline').on('updated', @hide_scrollbar_cb)

      # load tumblr news when start is done
      @body.on('loaded', '#start', @tumblr_cb)

      # load start pane
      # @start() unless @body.hasClass 'phone'


    # hide any scrollbar inside overflow:hidden
    hide_scrollbar_cb : (e) => @hide_scrollbar(e.target)
    hide_scrollbar : (element) ->
      inner = $(element)
      inner.css('width', "#{2 * inner.width() - element.scrollWidth}px")
      inner.off('updated',  @hide_scrollbar_cb)

    # display start pane
    display_start_cb : (e) => @display_start($(e.currentTarget))
    display_start : (link) ->
      link.parents('#start').addClass('focused')
      @body.removeClass('two-columns')
      @body.addClass('three-columns')

    # reset to showing timeline
    reset_cb : (e) => @reset()
    reset : ->
      static_content = @body.find('#static-content')

      # remove all additional panes
      static_content.nextAll("section").remove()

      # hide all in static-content
      static_content.children().hide()

      # show timeline
      @body.find('#timeline').show()

      # show static-content
      static_content.removeClass('hidden')

    # load start pane
    start_cb : (e) => @start()
    start : ->
      start = $('<section />', id : 'start', class : 'right').data('source', '/profile/start')

      # clear right
      @body.find('.right').remove()

      # put start in #rightc and load
      $(document.body).append(start)

      # load start
      replay.utils.load_source(start)

    # load news from tumblr
    tumblr_cb : (e) => @tumblr($('#tumblr-news'))
    tumblr : (tumblr) ->
      return true unless tumblr.length
      tumblr.on('loaded', (e) -> e.stopPropagation())
      tumblr.on('load-fail', => $(this).html(@tumblr_error_msg))
      replay.utils.load_source(tumblr)

    # unselect menu items
    unselect_cb : (e) => @unselect(@body)
    unselect : (body) ->
      body.find('.menu a').removeClass('selected')

    # focus the search box
    # remove all dynamic opened panes
    search_focus_cb : (e) => @search_focus(@body)
    search_focus : (body) ->
      body.find('#static-content').nextAll('section').remove()
      body.find('#static-content').removeClass('hidden')
      body.addClass('two-columns').removeClass('three-columns')

    # toggle follow/unfollow
    follow_toggle_cb : (e) => @follow_toggle($(e.currentTarget)) and false
    follow_toggle : (link) ->
      return unless link.hasClass('follow') or link.hasClass('unfollow')
      link.removeClass('follow unfollow')

      # request follow/unfollow and update link
      $.get(link.attr('href'), (data) ->
        link.text(data.class)
        link.attr('href', data.href)
        link.addClass(data.class))

    # copy to clipboard
    copy_clipboard_cb : (e) =>
      @copy_clipboard($(e.currentTarget))
      return false

    copy_clipboard : (link) -> window.prompt('Copy to clipboard: Ctrl+C, Enter', link.attr('href'))

    # display search result pane on searching
    searching_cb : (e) => @searching($(e.currentTarget))
    searching : (search_result) ->
      search_result.siblings().hide()
      search_result.show()
      section = search_result.parents('section')
      # remove all but #static-content
      section.nextAll('section').remove()
      # display middlec
      section.removeClass('hidden')

  exports.init = ->
    body = $(document.body)
    return unless body.hasClass('profile')

    # init menu
    menu = new Menu body, $('.menu')
    navigation = new Navigation body
    timeline = new Timeline $('#timeline')
    review = new Review body
    profile = new Profile body

    # load right pane
    replay.utils.load_source(body.find('.right[data-source]'))

# $(document).ready()
$ -> replay.profile.init()
