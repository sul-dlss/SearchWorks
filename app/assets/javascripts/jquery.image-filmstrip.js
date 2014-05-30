(function($) {
  /*
    jQuery plugin to render Google book covers for image elements

      Usage: $(selector).imgFilmStrip();

    This plugin :
      - renders filmstrip view for elements with 'image-filmstrip' class
        and attaches navigation events
  */

  $.fn.imgFilmStrip = function() {

    return this.each(function() {
      var $parent = $(this),
          $viewport,
          $listing;

      init();

      function init() {
        var listingTotalWidth = 0,
            listImgs = [];

        $viewport = $parent.find('.viewport');
        $listing  = $parent.find('.listing');

        listImgs  = $listing.find('li a img');

        listImgs.width($parent.data('thumb-width')).height($parent.data('thumb-height'));

        listingTotalWidth = listImgs.length * ($parent.data('thumb-width') + 10);

        $listing.width(listingTotalWidth).height($parent.data('thumb-height'));

        attachEvents();
        loadThumbsInViewport();
      }


      function loadThumbsInViewport() {
        $.each($listing.find('li a img'), function(index, img) {
          var $img = $(img),
              position = $img.position().left + $img.width();

          if (position > 0 && $img.position().left < $viewport.width()) {
            $img.attr('src', $img.data('url'));
          }
        });
      }


      function scrollBy(direction) {
        var scrollLeft = $viewport.scrollLeft(),
            viewportWidth = $viewport.width();

        if (direction === 'right') {
          $viewport.scrollLeft(scrollLeft + viewportWidth);
        }

        if (direction === 'left') {
          $viewport.scrollLeft(scrollLeft - viewportWidth);
        }
      }


      function attachEvents() {
        $viewport.scrollStop(function() {
          loadThumbsInViewport();
        });

        $(window).resize(function() {
          loadThumbsInViewport();
        });

        $parent.find('.prev').on('click', $.proxy(function() {
          scrollBy('left');
        }, this));

        $parent.find('.next').on('click', $.proxy(function() {
          scrollBy('right');
        }, this));
      }

    });

  };

})(jQuery);


// source: http://stackoverflow.com/questions/14035083/jquery-bind-event-on-scroll-stops
jQuery.fn.scrollStop = function(callback) {
  $(this).scroll(function() {
    var self  = this,
    $this = $(self);

    if ($this.data('scrollTimeout')) {
      clearTimeout($this.data('scrollTimeout'));
    }

    $this.data('scrollTimeout', setTimeout(callback, 250, self));
  });
};


Blacklight.onLoad(function() {
  $('.image-filmstrip').imgFilmStrip();
});

