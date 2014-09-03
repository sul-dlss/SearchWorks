(function($) {

  /*
    jQuery plugin to toggle accordion section content

      Usage: $(selector).accordionSection();
  */


  $.fn.accordionSection = function() {

    return this.each(function() {
      var $header = $(this),
          $target = $($header.data('accordion-section-target')),
          $snippet = $($header.data('accordion-section-target') + '-snippet'),
          clsAccordionClose = 'glyphicon-chevron-right',
          clsAccordionOpen = 'glyphicon-chevron-down';

      attachEvents();

      function attachEvents() {
        $header.on('click', $.proxy(function() {
          var $arrow = $header.find('span.glyphicon');

          if ($arrow.hasClass(clsAccordionClose)) {
            $arrow.removeClass(clsAccordionClose).addClass(clsAccordionOpen);
            $target.show();
            $snippet.hide();
          } else {
            $arrow.removeClass(clsAccordionOpen).addClass(clsAccordionClose);
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
