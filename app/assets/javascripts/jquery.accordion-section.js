(function($) {

  /*
    jQuery plugin to toggle accordion section content

      Usage: $(selector).accordionSection();
  */


  $.fn.accordionSection = function() {

    return this.each(function() {
      let button = this;
      var $header = $(this),
          $target = $($header.data('accordion-section-target')),
          $snippet = $($header.data('accordion-section-target') + '-snippet')

      attachEvents();

      function attachEvents() {
        $header.on('click', $.proxy(function(event) {
          button.classList.toggle('open')
          if (button.classList.contains('open')) {
            $target.show();
            $snippet.hide();
            $target.attr('aria-expanded', true);
            button.setAttribute('aria-expanded', true);
          } else {
            $target.hide();
            $snippet.show();
            $target.attr('aria-expanded', false);
            button.setAttribute('aria-expanded', false);
          }
        }, this));
      }

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-accordion-section-target]').accordionSection();
});
