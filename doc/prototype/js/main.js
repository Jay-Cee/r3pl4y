function init() {
	init_search();
	init_nav_tabs();
	init_user_preview();
	init_img_balloon();
	init_game_preview();
	init_game_review();
}

/* Place a handler on search query input
 * so when it focuses, empties the input
 */
function init_search() {
	// When search box gets focus
	$('#search .query').focus(function () {
		// Empty its value
		$(this).val('');
		});
}

function init_nav_tabs() {
	// When nav tab link is clicked
	$('nav.tabs a').click(function () {
		// Remove active class from any tab
		$('nav.tabs li').removeClass('active');

		// Place active class on link parent
		$(this).parent().addClass('active');

		// Hide content of previous tab
		$('#main section.active').removeClass('active');

		// Make new tab visible
		$($(this).attr('href')).addClass('active');

		// Stop browser from navigating to anchor
		return false;
		});
}

function init_user_preview() {
	$(document).on('click', '.user-preview', {}, function () {
		var href = $(this).attr('href');
		var userPreviewContent = $('#user-preview .content');

		userPreviewContent.load(href);

		$('#user-preview').show();
		$('#profile').hide();

		return false;
		});

	$('#user-preview .close').click(function() {
		$('#user-preview').hide();
		$('#profile').show();
		return false;
		});
}

function init_img_balloon() {
	$(document).on('mouseover', 'img[title]', {}, function () {
		console.debug("inside");
			var img = $(this);
			var body = $('body');
			body.append('<span id="balloon">' + $(this).attr('title') + '</span>');

			var balloon = $('#balloon');
			var top = img.offset().top - balloon.height() - 15;
			var left = (img.offset().left + (img.width() / 2)) - (balloon.width() / 2);
			balloon.css("top", top + "px");
			balloon.css("left", left + "px");
		});
	
	$(document).on('mouseout', 'img[title]', {}, function () {
		console.debug("outside");
		$('#balloon').remove();
		});

	$(document).on('click', 'img[title]', {}, function () {
		console.debug("outside");
		$('#balloon').remove();
		});
}

function init_game_preview() {
	$(document).on('click', 'a.game-preview', {}, function () {
		$(this).colorbox({ 'open': true, 'opacity': 0.6 });
		return false;
		});
}

function init_game_review() {
	$(document).on('click', '#rate-form input', {}, function () {
		$('#review-text').empty();
		$('#review-text').focus();
		});
	
	$(document).on('click', '#button-submit', {}, function () {
		$.fn.colorbox.close();
		});
}

/* Run init on document ready */
$(document).ready(init);
