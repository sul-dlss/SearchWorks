(function($) {

  /*
    jQuery plugin to toggle accordion section content

      Usage: $(selector).accordionSection();
  */


  $.fn.accordionSection = function() {

    return this.each(function() {
      var $header = $(this),
          $target = $($header.data('accordion-section-target')),
          $snippet = $($header.data('accordion-section-target') + '-snippet');

      attachEvents();

      function attachEvents() {
        $header.on('click', $.proxy(function() {
          var $arrow = $header.find('i.fa');

          if ($arrow.hasClass('fa-caret-right')) {
            $arrow.removeClass('fa-caret-right').addClass('fa-caret-down');
            $target.show();
            $snippet.hide();
          } else {
            $arrow.removeClass('fa-caret-down').addClass('fa-caret-right');
            $target.hide();
            $snippet.show();
          }
        }, this));
      }

    });

  }

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-accordion-section-target]').accordionSection();
});
