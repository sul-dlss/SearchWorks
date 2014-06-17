(function($) {
  /*
    jQuery plugin to render images in a collection as a filmstrip

      Usage: $(selector).renderFilmstrip();

    This plugin :
      - renders filmstrip view for elements with 'image-filmstrip' class
        and attaches navigation events
  */

  $.fn.renderFilmstrip = function() {

    return this.each(function() {
      var $filmstrip = $(this),
          $viewport,
          $containerImgs,
          imgs = [];

      init();

      function init() {
        var listingTotalWidth = 0;

        $viewport = $filmstrip.find('.viewport');
        $containerImgs = $viewport.find('.container-images');
        imgs = $containerImgs.find('li a img');

        imgs.width($filmstrip.data('thumb-width')).height($filmstrip.data('thumb-height'));

        listingTotalWidth = imgs.length * ($filmstrip.data('thumb-width') + 10); /* 10 => margin in px */

        $containerImgs.width(listingTotalWidth).height($filmstrip.data('thumb-height'));

        attachEvents();
        loadThumbsInViewport();
      }


      function loadThumbsInViewport() {
        $containerImgs.find('li').each(function() {

          var $item = $(this),
              $img = $item.find('a img').first(),
              position = $item.position().left + $img.width();

          if (position > 0 && $item.position().left < $viewport.width()) {
            $img.attr('src', $img.data('url'));
          }
        });
      }


      function scroll(direction) {
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

        $filmstrip.find('.prev').on('click', $.proxy(function() {
          scroll('left');
        }, this));

        $filmstrip.find('.next').on('click', $.proxy(function() {
          scroll('right');
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
  $('.image-filmstrip').renderFilmstrip();
});

