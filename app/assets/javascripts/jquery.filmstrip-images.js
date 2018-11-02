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

        listingTotalWidth = (imgs.length + 1) * ($filmstrip.data('thumb-width') + 10); /* 10 => margin in px */

        $containerImgs.width(listingTotalWidth).height($filmstrip.data('thumb-height'));

        // Change all data-alts to alts
        $.each(imgs, function() {
          var $img = $(this);
          $img.prop('alt', $img.data('alt'));
          $img.removeAttr('data-alt');
        });

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

      function attachEvents() {
        $viewport.scrollStop(function() {
          loadThumbsInViewport();
        });

        $(window).resize(function() {
          loadThumbsInViewport();
        });
      }

    });

  };

})(jQuery);


// source: http://stackoverflow.com/questions/14035083/jquery-bind-event-on-scroll-stops
// A.K.A. a debounce function.
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
