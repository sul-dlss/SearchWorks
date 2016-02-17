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
        $header.on('click', $.proxy(function(event) {
          var $arrow = $header.find('span.glyphicon');

          if ($arrow.hasClass(clsAccordionClose)) {
            $arrow.removeClass(clsAccordionClose).addClass(clsAccordionOpen);
            $target.show();
            $snippet.hide();
            $target.attr('aria-expanded', true);
            $(event.target).attr('aria-expanded', true);
          } else {
            $arrow.removeClass(clsAccordionOpen).addClass(clsAccordionClose);
            $target.hide();
            $snippet.show();
            $target.attr('aria-expanded', false);
            $(event.target).attr('aria-expanded', false);
          }
        }, this));
      }

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-accordion-section-target]').accordionSection();
});
