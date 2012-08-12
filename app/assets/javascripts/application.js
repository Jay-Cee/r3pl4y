// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

/*
 * throttledresize: special jQuery event that happens at a reduced rate compared to "resize"
 *
 * latest version and complete README available on Github:
 * https://github.com/louisremi/jquery-smartresize
 *
 * Copyright 2012 @louis_remi
 * Licensed under the MIT license.
 *
 * This saved you an hour of work?
 * Send me music http://www.amazon.co.uk/wishlist/HNTU0468LQON
 */
(function ($) {
    
    "use strict";

    var $event = $.event,
        $special,
        dummy = { _: 0 },
        frame = 0,
        wasResized, animRunning;

    $special = $event.special.throttledresize = {
        setup: function () {
            $(this).on("resize", $special.handler);
        },
        teardown: function () {
            $(this).off("resize", $special.handler);
        },
        handler: function (event, execAsap) {
            // Save the context
            var context = this,
                args = arguments;

            wasResized = true;

            if (!animRunning) {
                $(dummy).animate(dummy, { duration: Infinity, step: function () {
                    frame += 1;

                    if (frame > $special.threshold && wasResized || execAsap) {
                        // set correct event type
                        event.type = "throttledresize";
                        $event.dispatch.apply(context, args);
                        wasResized = false;
                        frame = 0;
                    }
                    if (frame > 9) {
                        $(dummy).stop();
                        animRunning = false;
                        frame = 0;
                    }
                }});
                animRunning = true;
            }
        },
        threshold: 0
    };

}(jQuery));
